/****************************************************************
****************************************************************
File:		2_table_a1.do
Purpose:	Generate Table A1


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
clear all
use "$data/generated/hi_analysis_daily.dta", clear 

	label var heat_index "Heat Index"

	reghdfe m_quality_output heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	
	reghdfe m_total_entries heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ m_total_entries if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	
	reghdfe m_typing_time heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ m_typing_time if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	
	reghdfe m_mistakes_number heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ m_mistakes_number if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	
	reghdfe performance_earnings_hr heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ performance_earnings_hr if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	
	#delimit ;
	esttab * using "$output/tables/table_a1.tex",  replace 
		$esttab_opts
		scalars("mean Dependent Variable Mean"  "r2 R-squared" "num_obs Observations")
		mtitles("\textbf{\shortstack{Quality Adjusted\\ Output}}" 
				"\textbf{\shortstack{Total Number of\\ Entries}}" 
				"\textbf{\shortstack{Active Typing\\ Time}}" 
				"\shortstack{\textbf{Mistakes} (per 100\\ entries)}" 
				"\textbf{\shortstack{Performance\\Earnings}}") 
		mgroups("Dependent Variable is \textbf{Average Hourly}",  
			pattern(1 0 0 0 0) 
			prefix(\multicolumn{@span}{c}{) suffix(}) 
			span erepeat(\cmidrule(lr){@span})) ;

	#delimit cr;
