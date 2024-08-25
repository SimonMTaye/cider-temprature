// TODO: Check

/****************************************************************
****************************************************************
File:		2_table_3.do
Purpose:	Generate Table 3: Differential Effects of Temperature on
		Learning on the Job

Author:		Isadora Frankenthal
Modified By:	Simon Taye
****************************************************************
****************************************************************/
clear all 
use "$data/generated/hi_analysis_daily.dta", clear 
*** beg vs end table 
	xtset pid day_in_study
	
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

	esttab * using "$output/tables/table_3.rtf", replace ///
		scalars("coeff_sum Sum of Coefficients" "p_value p-value of Sum" "num_obs Observations" "r2 R-squared") ///
		mtitles("First Half of the Study" "Second Half of the Study" "No Prior Computer Ability" "Prior Computer Ability") ///
		label noobs nodepvars nocons keep(temp_c_two_days)  mgroups("Dependent Variable is Average Quality Adjusted Output (per hour)", pattern(1 1 1 1))

