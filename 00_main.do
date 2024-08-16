/****************************************************************
****************************************************************
File:		00_main
Purpose:	Setup paths and install required packages
		

Author:		Simon Taye
****************************************************************
****************************************************************/
*** Set path variables
	local cwd : pwd
	* If 00_main.do is not being run from within the code folder of the research package, set path to package here
	global root "`cwd'/.."

	global data "$root/data"
	
*** Install Required Packages
	cap ssc install winsor

*** Runing cleaning do files
	do "$root/code/11_temp.do"
	do "$root/code/12_merge_temp_prod.do"
	do "$root/code/13_lags_baseline.do"
