/****************************************************************
****************************************************************
File:		1_6_merge_cog_ab
Purpose:	Merge congition and absenteeism data

Author:		Isadora Frankenthal

Modified By:	Simon Taye
Note:		Adapated from cognition.do
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear  

	merge 1:1 pid day_in_study using "$data/raw/cognitive_tasks_dataset.dta"
		drop if _merge == 2
		drop _merge

	merge 1:1 pid day_in_study using "$data/raw/pvt_dataset.dta" 
		drop if _merge == 2
		drop _merge

	merge 1:1 pid day_in_study using "$data/raw/absenteeism.dta"
		drop if _merge == 2
		drop _merge

	merge 1:1 pid day_in_study using "$data/raw/checkin_checkout.dta"
		drop if _merge == 2
		drop _merge

	* cognition index for table a5
	foreach var in pv_perf co_payment hf_payment {
		gen `var'_st = . 
		sum `var', d 
		replace `var'_st = (`var' - r(mean))/r(sd)
	}
	swindex pv_perf_st co_payment_st hf_payment_st, generate(cognitive_index) 

save "$data/generated/hi_analysis_daily.dta", replace


