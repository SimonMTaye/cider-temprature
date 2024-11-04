/****************************************************************
****************************************************************
File:		2_table_a11.do
Purpose:	Generate Table A11: Balance in Ability across seasons

Author:		Isadora Frankenthal

Modified By:	Simon Taye

Note:		FIX: Paper table note suggests 452 obs but there are 600+ in baseline
****************************************************************
****************************************************************/
use "$data/raw/baseline_cleaned.dta", clear 
	
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

	* Collapse so one observation per person
	*gen one = 1
	*collapse (first) one, by(english computer total_edu_yrs threetimesnine pid two_seasons)


	label var english "Literate in English (=1)"
	label var computer "Prior Computer Experience (=1)"
	label var total_edu_yrs "Years of Education"
	label var threetimesnine "Math Ability (=1)"

	foreach var of varlist english computer total_edu_yrs threetimesnine {
    * Perform the t-test and store the results
    estpost ttest `var', by(two_seasons)
    
    * Calculate standard deviation for group 1 (two_seasons == 0)
    quietly summarize `var' if two_seasons == 0, meanonly
    local sd_1 = r(sd)
    * Calculate standard deviation for group 2 (two_seasons == 1)
    quietly summarize `var' if two_seasons == 1, meanonly
    local sd_2 = r(sd)
    
    * Add the standard deviations to the estimation results
    estadd scalar sd_1 = `sd_1'
    estadd scalar sd_2 = `sd_2'
    
    * Store the estimation results for each variable
    eststo `var'
	}

	table_header "" 3
	local header prehead(`r(header_macro)')
	model_titles "\textbf{April-September}" "\textbf{October-March}" "\textbf{p-value 1 = 2}"
	local titles `r(model_title)'

	* Output the table with variables in rows and statistics in columns using estout
	esttab english computer total_edu_yrs threetimesnine using "$output/tables/table_a11.tex", replace ///
    cells("mu_1(fmt(%5.3f)) mu_2(fmt(%5.3f)) p(fmt(%5.3f))" "sd_1(fmt(%5.3f)) sd_2(fmt(%5.3f)) .") ///
    label `header' `titles'


		*cells("mu_1(label(April-September)) mu_2(label(October-March)) p(label(p-value 1 = 2))" ///
		*	   "sd_1(par label()) sd_2(par label( )) .") label
		*cells("mu_1(label(April-September) sd_1(par)) mu_2(label(October-March)) p(label(p-value 1 = 2))") label ///
