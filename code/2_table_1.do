/****************************************************************
****************************************************************
File:		2_table_1.do
Purpose:	Generate Table 1: Temperature Effect on Hourly Avg Productivity results 

Author:		Isadora Frankenthal
Modified By:	Simon Taye
****************************************************************
****************************************************************/
clear all
use "$data/generated/hi_analysis_daily.dta", clear 
*******
	label var temperature_c "Temperature (Celcius)"
	
		* average productivity per hour 
	reghdfe m_quality_output temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

		
		* average entries per hour
	reghdfe m_total_entries temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_total_entries if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

		* average typing time
	reghdfe m_typing_time temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_typing_time if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo


		* average mistakes
	reghdfe m_mistakes_number temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ m_mistakes_number if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo


		* average earnings
	reghdfe performance_earnings_hr temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ performance_earnings_hr if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

	

	esttab * using "$output/tables/table_1.tex", replace ///
		scalars("mean Dependent Variable Mean"  "r2 R-squared" "num_obs Observations") ///
		mtitles("\textbf{\shortstack{Quality\\Adjusted\\Output}}" "\textbf{\shortstack{Total Number\\of Entries}}" "\textbf{\shortstack{Active Typing\\Time}}" "\shortstack{\textbf{Mistakes} (per\\ 100 entries)}" "\textbf{\shortstack{Performance\\Earnings}}") ///
		keep(temperature_c) $esttab_opts ///
		mgroups("Dependent Variable is \textbf{Average Hourly}", pattern(1 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))

