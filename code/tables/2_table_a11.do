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

	estpost ttest english computer total_edu_yrs threetimesnine, by(two_seasons)
	esttab . using "$output/tables/table_a11.tex", replace  nonum noobs ///
		cells("mu_1 mu_2 p" "sd_1 sd_2 .") label ///
		collabels("\textbf{April-September}" "\textbf{October-March}" "\textbf{p-value 1 = 2}")


		*cells("mu_1(label(April-September)) mu_2(label(October-March)) p(label(p-value 1 = 2))" ///
		*	   "sd_1(par label()) sd_2(par label( )) .") label
		*cells("mu_1(label(April-September) sd_1(par)) mu_2(label(October-March)) p(label(p-value 1 = 2))") label ///
