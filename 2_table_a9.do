//TODO: Check

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
clear all 
use "$data/generated/hi_analysis_daily.dta", clear 
	xtset pid day_in_study
	
	reghdfe m_quality_output temperature_c ld1_temperature_c ld2_temperature_c ld3_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
		* Calculate the sum of the coefficients
		estadd scalar coeff_sum = _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp]
		test _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] = 0 
		estadd scalar p_value = r(p)
	eststo
	
	reghdfe m_quality_output temperature_c ld1_temperature_c ld2_temperature_c ld3_temperature_c ld4_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
		* Calculate the sum of the coefficients
		estadd scalar coeff_sum = _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] + _b[ld4_temp]
		test _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] + _b[ld4_temp] = 0 
		estadd scalar p_value = r(p)
	eststo
	
	
	reghdfe m_quality_output temperature_c ld1_temperature_c ld2_temperature_c ld3_temperature_c ld4_temperature_c ld5_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
		* Calculate the sum of the coefficients
		estadd scalar coeff_sum = _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] + _b[ld4_temp] + _b[ld5_temp]
		test _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] + _b[ld4_temp] + _b[ld5_temp] = 0 
		estadd scalar p_value = r(p)
	eststo

	esttab * using "$output/tables/table_a9.rtf", replace ///
		scalars("coeff_sum Sum of Coefficients" "p_value p-value of Sum" "num_obs Observations" "r2 R-squared") ///
		mtitles("N = Three Leads" "N = Four Leads" "N = Five Leads") ///
		label noobs nodepvars nocons keep(temp_c_two_days)  mgroups("Dependent Variable is Average Quality Adjusted Output (per hour)", pattern(1 1 1 1))


