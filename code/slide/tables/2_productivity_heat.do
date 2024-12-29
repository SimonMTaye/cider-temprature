/****************************************************************
****************************************************************
File:		2_table_a1.do
Purpose:	Generate Table A1


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
eststo clear
use "$data/generated/hi_analysis_daily.dta", clear 

	label var heat_index "Heat Index"
	

 	// Indep var is heat index + 6 lags
	local indep_vars heat_index
	forvalues i=1/6 {
		local indep_vars `indep_vars' l`i'_heat_index
	}

	reghdfe m_quality_output `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ m_quality_output if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe m_total_entries `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ m_total_entries if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe m_typing_time `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ m_typing_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe m_mistakes_number `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ m_mistakes_number if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe performance_earnings_hr `indep_vars', absorb(pid day_in_study month#year) cluster(pid)
		summ performance_earnings_hr if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	table_header "Dependent Variable is \textbf{Average Hourly}" 5
	local header prehead(`r(header_macro)')
	model_titles "\textbf{\shortstack{Quality Adjusted\\ Output}}" "\textbf{\shortstack{Total Number\\of Entries}}" "\textbf{\shortstack{Active Typing\\Time}}" "\shortstack{\textbf{Mistakes} (per\\ 100 entries)}" "\textbf{\shortstack{Performance\\Earnings}}"
	local titles `r(model_title)'

	
	#delimit ;
	esttab * using "$output/tables/table_heatindex_slides.tex",  replace ///
		scalars("mean Dependent Variable Mean"  "num_obs Observations" "r2 R-squared" ) ///
		$esttab_opts `header' `titles' keep(heat_index);
	#delimit cr;
