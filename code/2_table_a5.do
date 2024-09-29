/****************************************************************
****************************************************************
File:		2_table_a5.do
Purpose:	Generate Table A5: Effect of Temperature on Abseentism


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
clear all
use "$data/generated/hi_analysis_daily.dta", clear 

	reghdfe at_present_check temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		sum cognitive_index if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe checkin_time temperature_c if hrs_of_work!=., absorb(pid day_in_study month#year) cluster(pid)
		sum cognitive_index if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe checkout_time temperature_c if hrs_of_work!=., absorb(pid day_in_study month#year) cluster(pid)
		sum cognitive_index if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe hrs_of_work temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		sum cognitive_index if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	esttab * using "$output/tables/table_a5.rtf",  replace ///
		scalars("mean Dependent Variable Mean"  "r2 R-squared" "num_obs Observations") ///
		mtitles("Quality Adjusted Output (per hr)" "Total Number of Entries (per hr)" "Active Time Typing (min/hr)" "Mistakes (per 100 entries)" "Performance Earnings (per hr)") ///
		label noobs nodepvars nocons 
	

