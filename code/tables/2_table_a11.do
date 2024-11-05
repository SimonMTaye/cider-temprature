/****************************************************************
****************************************************************
File:		2_table_a11.do
Purpose:	Generate Table A11: Balance in Ability across seasons

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
// Get dropout category
	use "$data/raw/analysis_base.dta", clear
		egen tag = tag(pid)
		keep if tag == 1
		keep pid dropout_category
		tempfile dropout_data
		save `dropout_data'

use "$data/raw/baseline_cleaned.dta", clear 

	merge 1:1 pid using `dropout_data'
	keep if dropout_category != 2

 	clear results
	eststo clear

	* used for balance table a11
	gen english = a15
	gen computer = a23
	* a18 what is 3 x 9 
	gen threetimesnine = a18 
	replace threetimesnine = 0 if threetimesnine!=1

	gen month = month(date)
	* Season code adapated from "balance.do"
	gen winter = 1 if inrange(month, 1, 3)
	replace winter = 0 if winter==. 
	
	gen summer = 1 if inrange(month, 4, 6)
	replace summer = 0 if summer==. 
	
	gen monsoon = 1 if inrange(month, 6, 9)
	replace monsoon = 0 if monsoon==. 
	
	gen post_monsoon = 1 if inrange(month, 10, 12)
	replace post_monsoon = 0 if post_monsoon==. 
	
	gen two_seasons = 1 if winter==1 | post_monsoon==1
	replace two_seasons = 0 if two_seasons==.

	label var english "Literate in English (=1)"
	label var computer "Prior Computer Experience (=1)"
	label var total_edu_yrs "Years of Education"
	label var threetimesnine "Math Ability (=1)"


	local outcome_vars english computer total_edu_yrs threetimesnine
	keep `outcome_vars' two_seasons
	* Perform the t-test and store the results
	eststo: estpost ttest `outcome_vars', by(two_seasons) //unequal

	local i 1
	foreach var of varlist `outcome_vars' {
		quietly summarize `var' if two_seasons == 0
		local sd = string(`r(sd)' / sqrt(`r(N)'), "%5.3f")	
		local row_`i' "&(`sd')"
		* Calculate standard deviation for group 2 (two_seasons == 1)
		quietly summarize `var' if two_seasons == 1
		local sd = string(`r(sd)' / sqrt(`r(N)'), "%5.3f")	
		local row_`i' "`row_`i'' &(`sd') & \\"
		local i = `i' + 1
	}

	local num_columns 3
  local header prehead("\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} {\begin{tabular}{l*{`num_columns'}{c}} \toprule")
	* Output the table with variables in rows and statistics in columns using estout
	local group_1 "\shortstack{\textbf{April-September}\\(1)}"
	local group_2 "\shortstack{\textbf{October-March}\\(2)}"
	local p_value "\shortstack{\textbf{p-value, 1 = 2}\\(3)}"

	local filename "$output/tables/table_a11.tex"

	#delimit ;
	esttab . using `filename', replace
    cells("mu_1(fmt(%5.3f) label(`group_1')) mu_2(fmt(%5.3f) label(`group_2')) p(fmt(%5.3f) label(`p_value'))")
		`titles' keep(`outcome_vars') noobs nocons nonum label nomtitle `header';

	#delimit cr;
  insert_line `filename' 5 "`row_1'"
  insert_line `filename' 7 "`row_2'"
  insert_line `filename' 9 "`row_3'"
  insert_line `filename' 11 "`row_4'"


		*cells("mu_1(label(April-September)) mu_2(label(October-March)) p(label(p-value 1 = 2))" ///
		*	   "sd_1(par label()) sd_2(par label( )) .") label
		*cells("mu_1(label(April-September) sd_1(par)) mu_2(label(October-March)) p(label(p-value 1 = 2))") label ///
		*collables("April-September" "October-March" "p-value, 1 = 2")
