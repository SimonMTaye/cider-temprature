/****************************************************************
****************************************************************
File:		2_table_a2.do
Purpose:	Generate Table A2: Temperature Effect on Hourly Avg Productivity results w/ Pollution


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
eststo clear
use "$data/generated/hi_analysis_daily.dta", clear 
	label var PM25		"PM 2.5"
	
	* average productivity per hour 
	reghdfe m_quality_output temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

	* average entries per hour
	reghdfe m_total_entries temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
		summ m_total_entries if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

	
	* average typing time
	reghdfe m_typing_time temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
		summ m_typing_time if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

	
	* average mistakes
	reghdfe m_mistakes_number temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
		summ m_mistakes_number if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

	
	* average earnings
	reghdfe performance_earnings temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
		summ performance_earnings if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

	table_header "Dependent Variable is \textbf{Average Hourly}" 5
	local header prehead(`r(header_macro)')
	model_titles "\textbf{\shortstack{Quality\\Adjusted\\Output}}" "\textbf{\shortstack{Total Number\\of Entries}}" "\textbf{\shortstack{Active Typing\\Time}}" "\shortstack{\textbf{Mistakes} (per\\ 100 entries)}" "\textbf{\shortstack{Performance\\Earnings}}"
	local titles `r(model_title)'

	
	#delimit ;
	esttab * using "$output/tables/table_a2.tex",  replace ///
		scalars("mean Dependent Variable Mean" "num_obs Observations" "r2 R-squared" ) ///
		$esttab_opts `header' `titles';
	#delimit cr;

