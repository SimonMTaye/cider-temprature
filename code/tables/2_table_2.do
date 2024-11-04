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
use "$data/generated/hi_analysis_daily.dta", clear 

	eststo clear
 	clear results

	// TODO Broken output

	* controlling for lags of depvar 
	xtset pid day_in_study

	* replacing missings with previous lags
	gen lag_output = l.m_quality_output
	replace lag_output = l2.m_quality_output if lag_output==.
	
	reghdfe m_quality_output temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
		estadd scalar coeff_sum =  .
		estadd scalar p_value = .
	eststo
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		estadd scalar num_obs = e(N)
		* Store number of observations
		estadd scalar coeff_sum =  _b[l3_temp] 
		* Perform the test and store the p-value
		test  _b[l3_temp] = 0 
		estadd scalar p_value = r(p)
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

	table_header "Dependent Variable is \textbf{Average Hourly Quality Adjust Output}" 4
	local header prehead(`r(header_macro)')
	model_titles "N = No Lags" "N = Three Lags" "N = Four Lags" "N = Five Lags" 
	local titles `r(model_title)'

	#delimit ;
	esttab * using "$output/tables/table_2.tex", replace ///
		scalars("coeff_sum Sum of Lagged Temperature Coefficients, Lag 3 to N" "p_value p-value" "num_obs Observations" "r2 R-squared") ///
		$esttab_opts keep(temperature_c) `header' `titles' ; ///
	#delimt cr;
		


