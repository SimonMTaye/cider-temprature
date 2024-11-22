/****************************************************************
****************************************************************
File:		2_table_a3.do
Purpose:	Generate Table A3


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear 


  // Independent variable is mean temperature for time in office and 6 lags
	local indep_vars temperature_c 
	forvalues i=1/6 {
		local indep_vars `indep_vars' l`i'_temperature_c 
	}

 	clear results
	eststo clear
	reghdfe quality_output `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ quality_output if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe total_entries `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ total_entries if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	

	reghdfe typing_time `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ typing_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	

	
	reghdfe mistakes_number `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ mistakes_number if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe performance_earnings `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ performance_earnings if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	

 	table_header "Dependent Variable is" 5
	local header prehead(`r(header_macro)')
	model_titles "\shortstack{\textbf{Quality Adjusted}\\ \textbf{Output} (per day)}"  "\shortstack{\textbf{Total Number of}\\ \textbf{Entries} (per day)}"  "\shortstack{\textbf{Active Typing}\\ \textbf{Time} (min/day)}"  "\shortstack{\textbf{Mistakes} (per 100\\ entries)}"  "\shortstack{\textbf{Performance}\\\textbf{Earnings}}"
	local titles `r(model_title)'

	#delimit ;
	esttab * using "$output/tables/table_productivity_daily_slide.tex",  replace ///
		scalars("mean Dependent Variable Mean"  "num_obs Observations" "r2 R-squared") ///
		$esttab_opts `header' `titles' keep(temperature_c);
	#delimit cr;

