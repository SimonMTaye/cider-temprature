// TODO: Check

/****************************************************************
****************************************************************
File:		2_table_2.do
Purpose:	Generate Table 2: Effects of Temperature Lags on learning
		on the job

Note:		- The paper drops the *lag output* variable but the note in the paper doesn't 
		specify that it is controlled for / included in the regression


Author:		Isadora Frankenthal
Modified By:	Simon Taye
****************************************************************
****************************************************************/
clear all 
use "$data/generated/hi_analysis_daily.dta", clear 
	* controlling for lags of depvar 
	xtset pid day_in_study
	
	* replacing missings with previous lags
	gen lag_output = l.m_quality_output
	gen second_lag_output = l2.m_quality_output
	replace lag_output = second_lag_output if lag_output==.
	
	reghdfe m_quality_output temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
		* Calculate the sum of the coefficients
		estadd scalar coeff_sum =  _b[l3_temp] + _b[l4_temp] 
		* Perform the test and store the p-value
		test  _b[l3_temp] + _b[l4_temp] = 0 
		estadd scalar p_value = r(p)
	eststo
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
		* Calculate the sum of the coefficients
		estadd scalar coeff_sum =  _b[l3_temp] + _b[l4_temp] + _b[l5_temp]
		* Perform the test and store the p-value
		test  _b[l3_temp] + _b[l4_temp] + _b[l5_temp] = 0 
		estadd scalar p_value = r(p)
	eststo

	esttab * using "$output/tables/table_2.rtf", replace ///
		scalars("coeff_sum Sum of Coefficients" "p_value p-value of Sum" "num_obs Observations" "r2 R-squared") ///
		mtitles("N = No Lags" "N = Three Lags" "N = Four Lags" "N = Five Lags") ///
		label noobs nodepvars nocons keep(temp_c_two_days)  mgroups("Dependent Variable is Average Quality Adjusted Output (per hour)", pattern(1 1 1 1))


