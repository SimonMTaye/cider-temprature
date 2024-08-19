/****************************************************************
****************************************************************
File:		00_main
Purpose:	Setup paths and install required packages
		

Author:		Simon Taye
****************************************************************
****************************************************************/

// INFO: I added time_india to the collapse command in 12_merge_temp_prod.do since it is used by productivity.do

// FIX: In `learning.do` The xtset command fails because pid day_in_study combos are not unqiue
// FIX: idk where to find the eop scheme package so i removed it
	* productivity.do
	* learning with bins.do

	

*** Set path variables
	local cwd : pwd
	* If 00_main.do is not being run from within the code folder of the research package, set path to package here
	global root "`cwd'/.."
	global data "$root/data"
	global output "$root/output"

	cap mkdir "$output"
	cap mkdir "$output/figures"
	cap mkdir "$output/tables"

	

	
local install_packages_flag 0
*** Install Required Packages
	if `install_packages_flag' == 1 {
		cap ssc install winsor
		cap ssc install reghdfe
		cap ssc install outreg2
	}

local cleaning_dos 0
*** Runing cleaning do files
	if `cleaning_dos' == 1 {
		do "$root/code/11_temp.do"
		do "$root/code/12_merge_temp_prod.do"
		do "$root/code/13_lags_baseline.do"
		do "$root/code/14_pollution.do"
	}


*** Run do files for figures and tables
	// INFO: Orginially named 'learning.do'
	do "$root/code/2_figure_1.do"
	// INFO: Generates results for Table A10
	// FIX: Output number of observations don't match up exactly - small discrepancies of 10 - 20
	// INFO: Orginially named 'learning growth rates.do'
	do "$root/code/2_table_a4.do"
	// INFO: Orignially part of productivity.do
	do "$root/code/2_table_a10.do"

local unsorted 0
**** Run unsorted figures
	if `unsorted' == 1 {
		do "$root/code/learning with temp bins.do" 
		do "$root/code/productivity.do"
		* do "$root/code/learning.do" -> has errror
	}

* Quit after running
exit, clear
