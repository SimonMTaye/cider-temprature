/****************************************************************
****************************************************************
File:		2_table_a4.do
Purpose:	Generate Table A4: Temperature Effect on Hourly Productivity results 


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_hourly.dta", clear 

	eststo clear

	label var temperature_c "Temperature (^{\circ}C)"

	
	reghdfe quality_output temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
		summ quality_output if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe total_entries temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
	summ total_entries if e(sample) == 1 
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	
	reghdfe typing_time temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
	summ typing_time if e(sample) == 1
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo


	
	reghdfe mistakes_number temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
	summ mistakes_number if e(sample) == 1
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo
	
	reghdfe performance_earnings temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
	summ performance_earnings if e(sample) == 1
	estadd scalar num_obs = e(N)
	estadd scalar mean = r(mean) 
	estadd scalar sd = r(sd)
	eststo


 	table_header "Dependent Variable is" 5

	#delimit ;
	esttab * using "$output/tables/table_a4.tex",  replace 
		$esttab_opts
		prehead(`r(header_macro)')
		scalars("mean Dependent Variable Mean" "num_obs Observations" "r2 R-squared")
		mlabels("\shortstack{\textbf{Quality Adjusted}\\ \textbf{Output} (per hr)}" 
				"\shortstack{\textbf{Total Number of}\\ \textbf{Entries} (per hr)}" 
				"\shortstack{\textbf{Active Typing}\\ \textbf{Time} (min/hr)}" 
				"\shortstack{\textbf{Mistakes} (per 100\\ entries)}" 
				"\shortstack{\textbf{Performance}\\\textbf{Earnings} (per hr)}"
			prefix(\multicolumn{@span}{c}{) suffix(}) 
			span erepeat(\cmidrule(lr){@span}));

	#delimit cr;

