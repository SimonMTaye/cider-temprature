/****************************************************************
****************************************************************
File:		2_table_1.do
Purpose:	Generate Table 1: Temperature Effect on Hourly Avg Productivity results 

Author:		Isadora Frankenthal
Modified By:	Simon Taye
****************************************************************
****************************************************************/

use "$data/generated/hi_analysis_daily.dta", clear 
*******
	eststo clear

  // Independent variable is mean temperature for time in office and 6 lags
	local indep_vars temperature_c 
	forvalues i=1/6 {
		local indep_vars `indep_vars' l`i'_temperature_c 
	}

		* average productivity per hour 
	reghdfe m_quality_output `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

		
		* average entries per hour
	reghdfe m_total_entries `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ m_total_entries if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

		* average typing time
	reghdfe m_typing_time `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ m_typing_time if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo


		* average mistakes
	reghdfe m_mistakes_number `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ m_mistakes_number if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo


		* average earnings
	reghdfe performance_earnings_hr `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ performance_earnings_hr if e(sample) == 1 
		estadd scalar mean = r(mean) 
		* Store number of observations
		estadd scalar num_obs = e(N)
	eststo

	table_header "Dependent Variable is \textbf{Average Hourly}" 5
	local header prehead(`r(header_macro)')
	model_titles "\textbf{\shortstack{Quality Adjusted\\Output}}" "\textbf{\shortstack{Total Number\\of Entries}}" "\textbf{\shortstack{Active Typing\\Time}}" "\shortstack{\textbf{Mistakes} (per\\ 100 entries)}" "\textbf{\shortstack{Performance\\Earnings}}"
	local titles `r(model_title)'

	
	#delimit ;
	esttab * using "$output/tables/table_productivity_slide.tex", replace ///
		scalars("mean Dependent Variable Mean"  "num_obs Observations" "r2 R-squared" ) ///
		keep(temperature_c) 
		$esttab_opts `header' `titles';
	#delimit cr;

