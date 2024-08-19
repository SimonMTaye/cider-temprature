/****************************************************************
****************************************************************
File:		2_table_a3.do
Purpose:	Generate Table A3


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
clear all
use "$data/generated/hi_analysis_daily.dta", clear 

	label var temperature_c "Temperature (Celcius)"

	reghdfe quality_output temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ quality_output if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	
	reghdfe total_entries temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ total_entries if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	


	
	reghdfe typing_time temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ typing_time if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	

	
	reghdfe mistakes_number temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ mistakes_number if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	
	reghdfe performance_earnings temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ performance_earnings if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	

	esttab * using "$output/tables/table_a3.rtf",  replace ///
		scalars("mean Dependent Variable Mean"  "r2 R-squared" "num_obs Observations") ///
		mtitles("Quality Adjusted Output (per hr)" "Total Number of Entries (per hr)" "Active Time Typing (min/hr)" "Mistakes (per 100 entries)" "Performance Earnings (per hr)") ///
		label noobs nodepvars nocons 
