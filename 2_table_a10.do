/****************************************************************
****************************************************************
File:		2_table_a10.do
Purpose:	Generate Table A10: Temperature Effect on Productivity Growth

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
//INFO: Switched from outreg2 to esttab to get formatting to work correctly

clear all
* learning with growth rates
use "$data/generated/hi_analysis_hourly.dta", clear 

	* define period to be every two days 
	sort pid day_in_study 
	gen two_days = 1 if inrange(day_in_study, 1, 2)
	replace two_days = 2 if inrange(day_in_study, 3, 4)
	replace two_days = 3 if inrange(day_in_study, 5, 6)
	replace two_days = 4 if inrange(day_in_study, 7, 8)
	replace two_days = 5 if inrange(day_in_study, 9, 10)
	replace two_days = 6 if inrange(day_in_study, 11, 12)
	replace two_days = 7 if inrange(day_in_study, 13, 14)
	replace two_days = 8 if inrange(day_in_study, 15, 16)
	replace two_days = 9 if inrange(day_in_study, 17, 18)
	replace two_days = 10 if inrange(day_in_study, 19, 20)
	replace two_days = 11 if inrange(day_in_study, 21, 22)
	replace two_days = 12 if inrange(day_in_study, 23, 24)
	replace two_days = 13 if inrange(day_in_study, 25, 26)
	replace two_days = 14 if inrange(day_in_study, 27, 28)
	
	* mean output/temp every two days 
	egen quality_output_two_days = mean(m_quality_output), by(pid two_days)
	egen temp_c_two_days = mean(temp_12_workday), by(pid two_days)
	egen hi_c_two_days = mean(hi_12_workday), by(pid two_days)
	
	
	* lags 
	gen l1_temp_c_two_days = (l1_temp_12 + l2_temp_12)/2
	gen l2_temp_c_two_days = (l3_temp_12 + l4_temp_12)/2
	gen l3_temp_c_two_days = (l5_temp_12 + l6_temp_12)/2
	gen l4_temp_c_two_days = (l7_temp_12 + l8_temp_12)/2
	gen l5_temp_c_two_days = (l9_temp_12 + l10_temp_12)/2
	
	gen l1_hi_c_two_days = (l1_hi_12 + l2_hi_12)/2
	gen l2_hi_c_two_days = (l3_hi_12 + l4_hi_12)/2
	gen l3_hi_c_two_days = (l5_hi_12 + l6_hi_12)/2
	gen l4_hi_c_two_days = (l7_hi_12 + l8_hi_12)/2
	gen l5_hi_c_two_days = (l9_hi_12 + l10_hi_12)/2
	
	
	
	* dummy for initial days when lags are not in the study period
	gen dummy2 = 0 if two_days<3
	replace dummy2 = 1 if dummy2==.
	gen dummy3 = 0 if two_days<4
	replace dummy3=1 if dummy3==.
	gen dummy4=0 if two_days<5
	replace dummy4=1 if dummy4==.
	gen dummy5=0 if  two_days<6
	replace dummy5=1 if dummy5==.
	
	replace computer = 0 if a24==1

	
	* collapse at two-day level
	
	
	collapse quality_output_two_days temp_c_two_days l* hi* (firstnm) computer english month year dummy*, by(pid two_days)
	
	sort pid two_days
	
	* gen growth rate 
	
	gen diff_quality_output_two_days = quality_output_two_days - quality_output_two_days[_n-1]
	replace diff_quality_output_two_days=. if two_days==1
	gen growth_quality_output_two_days = diff_quality_output_two_days/quality_output_two_days
	
	
	label var temp_c_two_days "Temperature (Celcius)"
	
	* contemporaneous 
	
	reghdfe growth_quality_output_two_days temp_c_two_days, absorb(pid two_days month#year) cluster(pid)
	estadd scalar num_obs = e(N)
	eststo
	
	
	reghdfe growth_quality_output_two_days temp_c_two_days if two_days<9, absorb(pid two_days month#year) cluster(pid)
	estadd scalar num_obs = e(N)
	eststo
		
	reghdfe growth_quality_output_two_days temp_c_two_days if computer==0, absorb(pid two_days month#year) cluster(pid)
	estadd scalar num_obs e(N)
	eststo
	
	

	* three lags 
	
	xtset pid two_days
	
	
	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days if dummy3==1, absorb(pid two_days month#year) cluster(pid)
	* Store number of observations
	estadd scalar num_obs = e(N)
	* Calculate the sum of the coefficients
	estadd scalar coeff_sum = _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
	* Perform the test and store the p-value
	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0
	estadd scalar p_value = r(p)
	eststo
		

	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days if dummy3==1 & two_days<9, absorb(pid two_days month#year) cluster(pid)
	* Store number of observations
	estadd scalar num_obs = e(N)
	* Calculate the sum of the coefficients
	estadd scalar coeff_sum = _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
	* Perform the test and store the p-value
	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0
	estadd scalar p_value = r(p)
	eststo
		
	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days if dummy3==1 & computer==0, absorb(pid two_days month#year) cluster(pid)
	* Store number of observations
	estadd scalar num_obs = e(N)
	* Calculate the sum of the coefficients
	estadd scalar coeff_sum = _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
	* Perform the test and store the p-value
	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0
	estadd scalar p_value = r(p)
	eststo

	esttab * using "$output/tables/table_a10.rtf", replace ///
		scalars("coeff_sum Sum of Coefficients" "p_value p-value of Sum" "num_obs Observations" "r2 R-squared") ///
		mtitles("Full Study Period" "First Half of the Study" "No Prior Computer Experience" "Full Study Period" "First Half of the Study" "No Prior Computer Experience") ///
		label noobs nodepvars nocons keep(temp_c_two_days) 


	
	
	
	
