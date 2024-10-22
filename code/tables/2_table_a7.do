/****************************************************************
****************************************************************
File:		2_table_a7.do
Purpose:	Generate Table A7: Effects of Temprature on Cognition


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear 

	eststo clear
	// TODO Fix scalar formatting

	reghdfe cognitive_index temperature_c, absorb(pid day_in_study month#year) cluster (pid) 
		sum cognitive_index if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	reghdfe pv_perf_st temperature_c, absorb(pid day_in_study month#year) cluster (pid) 
		sum pv_perf_st if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	reghdfe co_payment_st temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		sum cognitive_index if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo


	reghdfe hf_payment_st temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		sum hf_payment_st if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

		
	table_header "Dependent Variable is" 4
	local header prehead(`r(header_macro)')
	model_titles "\textbf{Cognition Index}"  "\textbf{PVT}"  "\textbf{Corsi}"  "\textbf{Hearts and Flowers}"
	local titles `r(model_title)'
	#delimit ;
	esttab * using "$output/tables/table_a7.tex", replace ///
		scalars("mean Dependent Variable Mean"  "num_obs Observations" "r2 R-squared") ///
		sfmt("%5.2f" "%5.0f" "%5.3f") ///
		$esttab_opts `header' `titles';
	#delimit cr;
