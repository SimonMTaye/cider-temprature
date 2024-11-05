/****************************************************************
****************************************************************
File:		2_table_a9.do
Purpose:	Generate Table A9: Effects of Temperature Leads on Learning
		on the job

Note:		- The paper drops the *lag output* variable but the note in the paper doesn't 
		specify that it is controlled for / included in the regression


Author:		Isadora Frankenthal
Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear 
	xtset pid day_in_study
	eststo clear
	
	reghdfe m_quality_output temperature_c ld1_temperature_c ld2_temperature_c ld3_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
		* Calculate the sum of the coefficients
		estadd scalar coeff_sum = _b[ld1_temperature_c] + _b[ld2_temperature_c] + _b[ld3_temperature_c]
		test _b[ld1_temperature_c] + _b[ld2_temperature_c] + _b[ld3_temperature_c] = 0 
		estadd scalar p_value = r(p)
	eststo
	
	reghdfe m_quality_output temperature_c ld1_temperature_c ld2_temperature_c ld3_temperature_c ld4_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
		* Calculate the sum of the coefficients
		estadd scalar coeff_sum = _b[ld1_temperature_c] + _b[ld2_temperature_c] + _b[ld3_temperature_c] + _b[ld4_temperature_c]
		test _b[ld1_temperature_c] + _b[ld2_temperature_c] + _b[ld3_temperature_c] + _b[ld4_temperature_c] = 0 
		estadd scalar p_value = r(p)
	eststo
	
	
	reghdfe m_quality_output temperature_c ld1_temperature_c ld2_temperature_c ld3_temperature_c ld4_temperature_c ld5_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
		* Calculate the sum of the coefficients
		estadd scalar coeff_sum = _b[ld1_temperature_c] + _b[ld2_temperature_c] + _b[ld3_temperature_c] + _b[ld4_temperature_c] + _b[ld5_temperature_c]
		test _b[ld1_temperature_c] + _b[ld2_temperature_c] + _b[ld3_temperature_c] + _b[ld4_temperature_c] + _b[ld5_temperature_c] = 0 
		estadd scalar p_value = r(p)
	eststo

	table_header "Dependent Variable is \textbf{Average Hourly Quality Adjusted Output}" 3
	local header prehead(`r(header_macro)')
	model_titles "N = Three Leads" "N = Four Leads" "N = Five Leads"
	local titles `r(model_title)'
	#delimit ;
	esttab * using "$output/tables/table_a9.tex", replace ///
		scalars("coeff_sum Sum of Lagged Temperature Coefficients, Lead 1 to N" "p_value p-value" "mean Dependent Variable Mean" "num_obs Observations" "r2 R-squared" ) ///
		keep(temperature_c) ///
		$esttab_opts `header' `titles';
	#delimit cr;




