/****************************************************************
****************************************************************
File:		2_table_3.do
Purpose:	Generate Table 3: Differential Effects of Temperature on
		Learning on the Job

Author:		Isadora Frankenthal
Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear 
	eststo clear
*** beg vs end table 
	xtset pid day_in_study
	* genearte lag outputs
	gen lag_output = l.m_quality_output
	gen second_lag_output = l2.m_quality_output
	replace lag_output = second_lag_output if lag_output==.

	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output if day_in_study>5 & day_in_study<15, absorb(pid day_in_study month#year) cluster(pid)
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

	
	
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output if day_in_study>18, absorb(pid day_in_study month#year) cluster(pid)
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

	
	** comp not comp 
	replace computer = 0 if a24==1
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output if computer==0 & day_in_study>5 & day_in_study<15, absorb(pid day_in_study month#year) cluster(pid)
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
	
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output if computer==1 & day_in_study>5 & day_in_study<15, absorb(pid day_in_study month#year) cluster(pid)
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

	table_header "Dependent Variable: \textbf{Average Hourly Quality Adjust Output}" 4
	local header prehead(`r(header_macro)')
	model_titles "\shortstack{First Half of\\ the Study}" "\shortstack{Second Half of\\ the Study}"  "\shortstack{No Prior\\ Computer Ability}"  "\shortstack{Prior Computer\\ Ability}"
	local titles `r(model_title)'

	#delimit ;
	esttab * using "$output/tables/table_3.tex", replace ///
		scalars("coeff_sum Sum of Lagged Temperature Coefficients, Lag 3 to N" "p_value p-value" "num_obs Observations" "r2 R-squared") ///
		$esttab_opts keep(temperature_c) `header' `titles' ; ///
		
	#delimit cr;



