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

	#delimit ;
	esttab * using "$output/tables/table_a9.tex",  replace
		$esttab_opts keep(temperature_c)
		scalars("coeff_sum Sum of Lagged Temperature Coefficients, Lead 1 to N" "p_value p-value" "mean Dependent Variable Mean" "r2 R-squared" "num_obs Observations") 
		mtitles("N = Three Leads" "N = Four Leads" "N = Five Leads") 
		mgroups("Dependent Variable is \textbf{Average Hourly Quality Adjusted Output}",
			pattern(1 0 0) 
			prefix(\multicolumn{@span}{c}{) suffix(}) 
			span erepeat(\cmidrule(lr){@span})) ; 

	#delimit cr 




