/****************************************************************
****************************************************************
File:		2_table_a11.do
Purpose:	Generate Table A11: Balance in Ability across seasons

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear 
	
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
	

	// Clear any previous estimates
	eststo clear

	// Initialize an empty model
	*estimates define empty

	// List of variables to test
	local vars english computer total_edu_yrs threetimesnine

	// Loop over each variable
	foreach var of local vars {
	    // Run ttest
	    estpost ttest `var', by(two_seasons)

	    // Extract and store results in scalars
	    scalar mean1 = r(mu_1)
	    scalar se1 = r(se_1)
	    scalar mean2 = r(mu_2)
	    scalar se2 = r(se_2)
	    scalar pvalue = r(p)
	    
	    // Add scalars to the model
	    estadd scalar mean1_`var' = mean1
	    estadd scalar se1_`var' = se1
	    estadd scalar mean2_`var' = mean2
	    estadd scalar se2_`var' = se2
	    estadd scalar pvalue_`var' = pvalue
	}
	eststo

	/* Store the results as an estimates model
	ttest english, by(two_seasons)
	// two_seasons = 0, mean .8011364 se .0301725 obs 176
	// two_seasons = 1, mean .7789855 se .025021 obs 276
	* p-value 0.5755 
	
	
	ttest computer, by(two_seasons)
	// two_seasons = 0, mean .25 se .03273 obs 176
	// two_seasons = 1, mean .304347 se .02774 obs 276
	* p-value 0.2120
	
	ttest total_edu_yrs, by(two_seasons)
	// two_seasons = 0, mean 9.982 se .21128 obs 176 
	// two_seasons = 1, mean 10.311 se .17592 obs 276
	* p-value 0.2369 
	
	* Additional math ability code in "balance.do" but omitted
	* because table notes only discusses threetimesnine

	/* a16 what is 8 + 14 
	gen eightplusfourteen = a16
	replace eightplusfourteen=0 if eightplusfourteen!=1 
	* a17 what is 12 + 7
	gen twelveminusseven = a17
	replace twelveminusseven=0 if twelveminusseven!=1 
	*egen math_score = rowtotal(eightplusfourteen twelveminusseven threetimesnine)
	*ttest math_score, by(two_seasons)
	*/

	ttest threetimesnine, by(two_seasons)
	eststo math_score
	*/


	// TODO: Table output doesn't match paper

	esttab . using "$output/tables/table_a11.rtf",  replace  ///
		scalars
		collabels("April-September" "October-March" "p-value, 1 = 2") 
