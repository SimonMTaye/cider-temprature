/****************************************************************
****************************************************************
File:		00_main
Purpose:	Setup paths and install required packages
		

Author:		Simon Taye
****************************************************************
****************************************************************/

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
	
	* Make empty directories that may not exist already
	cap mkdir "$data/generated"
	cap mkdir "$output"
	cap mkdir "$output/figures"
	cap mkdir "$output/tables"

	
local install_packages_flag 0
*** Install Required Packages
	if `install_packages_flag' == 1 {
		cap ssc install winsor
		cap ssc install reghdfe
		cap ssc install outreg2
		cap ssc install estout
	}

// FIX: Output number of observations don't match up exactly - small discrepancies of 10 - 20 for multiple tables
local cleaning_dos 0
*** Runing cleaning do files
	if `cleaning_dos' == 1 {
		do "$root/code/1_1_temp.do"
		do "$root/code/1_2_join_temp_prod.do"
		do "$root/code/1_3_merge_lags_baseline.do"
		do "$root/code/1_4_merge_pollution.do"
		do "$root/code/1_5_intermediate_vars.do"
	}


*** Run do files for figures and tables

local sorted 0
	if `sorted' == 1 {
		// INFO: Orginially named 'learning.do'
		do "$root/code/2_figure_1.do"
		// INFO: Orginially part of learning with temp bins.do
		do "$root/code/2_figure_2.do"
		// INFO: Orignially part of productivity.do
		do "$root/code/2_figure_a2.do"
		do "$root/code/2_table_1.do"
		// INFO: Orginially named 'learning.do'
		do "$root/code/2_table_2.do"
		do "$root/code/2_table_3.do"
		// INFO: Orignially part of productivity.do
		do "$root/code/2_table_a1.do"
		do "$root/code/2_table_a2.do"
		do "$root/code/2_table_a3.do"
		do "$root/code/2_table_a4.do"

		// INFO: Orginially part of learning with temp bins.do
		//do "$root/code/2_table_a5.do"

		// INFO: Orginially part of learning.do
		// INFO: Orginially part of learning.do
		do "$root/code/2_table_a8.do"
		do "$root/code/2_table_a9.do"
		// INFO: Orginially named 'learning growth rates.do'
		do "$root/code/2_table_a10.do"
	}

local unsorted 1
**** Run unsorted figures
	if `unsorted' == 1 {
		do "$root/code/learning with temp bins.do" 
	}

* Quit after running
clear all