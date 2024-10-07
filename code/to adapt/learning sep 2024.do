	
// 	* Learning

	clear all 
	global dir "/Users/isadorafrankenthal/Dropbox/Temperature/Data/2. Main Study" 

	use "$dir/01. Raw Data/Productivity/hi_analysis_daily.dta", clear 

	* learning for quality output 
	
	gen last_half = 0 
	replace last_half = 1 if day_in_study>14
	
	gen first_half = 0 
	replace first_half = 1 if day_in_study<=14
	
	gen day_in_study_beg = day_in_study*first_half
	gen day_in_study_end = day_in_study*last_half
	
	gen week1 = 0 
	replace week1 = 1 if day_in_study<=7 
	gen week2 = 0 
	replace week2 = 1 if day_in_study>=8 & day_in_study<=14 
	gen week3 = 0 
	replace week3=1 if day_in_study>14 & day_in_study<=21
	gen week4 = 0 
	replace week4=1 if day_in_study>=22
	
	gen day1to7 = day_in_study*week1
	gen day8to14 = day_in_study*week2
	gen day15to21 = day_in_study*week3
	gen day22to28 = day_in_study*week4

	
	** proof of learning table 
	
	reghdfe m_quality_output day_in_study, absorb(pid month#year) cluster(pid) 
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/proof_learning.xls", addstat("mean", r(mean), "sd", r(sd)) replace
	
	reghdfe m_quality_output day_in_study_beg day_in_study_end, absorb(pid month#year) cluster(pid) 
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/proof_learning.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe m_quality_output day1to7 day8to14 day15to21 day22to28, absorb(pid month#year) cluster(pid) 
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/proof_learning.xls", addstat("mean", r(mean), "sd", r(sd))
	
	
// 	** learning base table 
//	
// 	reghdfe m_quality_output temperature_c, absorb(pid day_in_study month#year) cluster(pid)
// 	summ m_quality_output if e(sample) == 1 
// 	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning.xls", addstat("mean", r(mean), "sd", r(sd)) replace
//	
// 	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
// 	summ m_quality_output if e(sample) == 1 
// 	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning.xls", addstat("mean", r(mean), "sd", r(sd))
//	
//	
// 	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
// 	summ m_quality_output if e(sample) == 1 
// 	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning.xls", addstat("mean", r(mean), "sd", r(sd))
// 	display  _b[l3_temp] + _b[l4_temp] + _b[l5_temp]
// 	test  _b[l3_temp] + _b[l4_temp] + _b[l5_temp] = 0 

	
	* controlling for lags of depvar 
	
	xtset pid day_in_study
	
	* replacing missings with previous lags
	gen lag_output = l.m_quality_output
	gen second_lag_output = l2.m_quality_output
	gen third_lag_output = l3.m_quality_output
	replace lag_output = second_lag_output if lag_output==.
	replace lag_output =  third_lag_output if lag_output==.
	
	
	
	reghdfe m_quality_output temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning.xls", addstat("mean", r(mean), "sd", r(sd)) replace 
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning.xls", addstat("mean", r(mean), "sd", r(sd))
	display  _b[l3_temp] + _b[l4_temp] 
	test  _b[l3_temp] + _b[l4_temp] = 0 
	
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning.xls", addstat("mean", r(mean), "sd", r(sd))
	display  _b[l3_temp] + _b[l4_temp] + _b[l5_temp]
	test  _b[l3_temp] + _b[l4_temp] + _b[l5_temp] = 0 
	
	
	
	
	* learning leads table 
	
	reghdfe m_quality_output temperature_c ld1_temperature_c ld2_temperature_c ld3_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_leads.xls", addstat("mean", r(mean), "sd", r(sd)) 
	di _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp]
	test _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] = 0 
	
	reghdfe m_quality_output temperature_c ld1_temperature_c ld2_temperature_c ld3_temperature_c ld4_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_leads.xls", addstat("mean", r(mean), "sd", r(sd)) 
	di _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] + _b[ld4_temp]
	test _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] + _b[ld4_temp] = 0 
	
	
	reghdfe m_quality_output temperature_c ld1_temperature_c ld2_temperature_c ld3_temperature_c ld4_temperature_c ld5_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_leads.xls", addstat("mean", r(mean), "sd", r(sd)) 
	di _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] + _b[ld4_temp] + _b[ld5_temp]
	test _b[ld1_temp] + _b[ld2_temp] + _b[ld3_temp] + _b[ld4_temp] + _b[ld5_temp] = 0 
	


	
	*** beg vs end table 
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output if day_in_study>5 & day_in_study<15, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_beg_vs_end.xls", addstat("mean", r(mean), "sd", r(sd)) replace
	
	display  _b[l3_temp] + _b[l4_temp] + _b[l5_temp] 
	test  _b[l3_temp] + _b[l4_temp] + _b[l5_temp]  = 0 
	
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output if day_in_study>18, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_beg_vs_end.xls", addstat("mean", r(mean), "sd", r(sd))
	
	display  _b[l3_temp] + _b[l4_temp] + _b[l5_temp]
	test  _b[l3_temp] + _b[l4_temp] + _b[l5_temp] = 0 
	
	
	** comp not comp 

	xtset pid day_in_study
	replace computer = 0 if a24==1
	
	gen computer2 = 0 
	replace computer2 = 1 if a24==3 | a24==4
	replace computer2 = . if a24==.
	egen comp2_max = max(computer2), by (pid)
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output if comp2_max==0 & day_in_study>5, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_beg_vs_end.xls", addstat("mean", r(mean), "sd", r(sd))
	
	display  _b[l3_temp] + _b[l4_temp] + _b[l5_temp] 
	test  _b[l3_temp] + _b[l4_temp] + _b[l5_temp]  = 0 
	
	
	reghdfe m_quality_output temperature_c l1_temperature_c l2_temperature_c l3_temperature_c l4_temperature_c l5_temperature_c lag_output if comp2_max==1 & day_in_study>5, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_beg_vs_end.xls", addstat("mean", r(mean), "sd", r(sd))

	display  _b[l3_temp] + _b[l4_temp] + _b[l5_temp] 
	test  _b[l3_temp] + _b[l4_temp] + _b[l5_temp]  = 0 

	

	