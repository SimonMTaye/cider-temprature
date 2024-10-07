/****************************************************************
****************************************************************
File:		2_table_a7.do
Purpose:	Generate Table A7: Effects of Temprature on Cognition


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
clear all 
use "$data/generated/hi_analysis_daily.dta", clear 

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

		
	#delimit ;
	esttab * using "$output/tables/table_a7.tex",  replace
		$esttab_opts
		scalars("mean Dependent Variable Mean"  "r2 R-squared" "num_obs Observations")
		mtitles("\textbf{Cognition Index}" 
				"\textbf{PVT}" 
				"\textbf{Corsi}" 
				"\textbf{Hearts and Flowers}")
		mgroups("Dependent Variable is" ,
			pattern(1 0 0 0) 
			prefix(\multicolumn{@span}{c}{) suffix(}) 
			span erepeat(\cmidrule(lr){@span})) ; 
	#delimit cr;
