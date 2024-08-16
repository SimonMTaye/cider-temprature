	
	* learning figure
	
// 	use "/Users/isadorafrankenthal/Dropbox/Temperature/Data/2. Main Study/01. Raw Data/Productivity/for_learning.dta", clear 

	clear all 
	global dir "/Users/isadorafrankenthal/Dropbox/Temperature/Data/2. Main Study" 
	
	use "$dir/01. Raw Data/Productivity/hi_analysis_daily.dta", clear 
	
	
	bysort pid: gen temp = m_quality_output if day_in_study==1
	bysort pid: egen day_1_quality = max(temp)
	gen m_quality_output_rel = m_quality_output/day_1_quality
	
	
	
 	preserve 
	
	collapse m_quality_output_rel, by(day_in_study)
	
	scatter m_quality_output_rel day_in_study, color(emerald) ytitle(Output Relative to First Day) xscale(r(1(1)28)) xlabel(2(2)28) legend(off) || qfit m_quality_output_rel day_in_study, color(emerald)
	graph export "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_all.pdf", replace
	
	restore 
	
	
	
	preserve 
	
	replace computer = 0 if a24==1
	
	collapse m_quality_output_rel, by(day_in_study computer)
	
	twoway (scatter m_quality_output_rel day_in_study if computer==0, color(eltblue)) (qfit m_quality_output_rel day_in_study if computer==0, lwidth(medium) color(eltblue)) (scatter m_quality_output_rel day_in_study if computer==1, color(navy) ytitle(Output Relative to First Day) xscale(r(1(1)28)) xlabel(2(2)28)) (qfit m_quality_output_rel day_in_study if computer==1, color(navy)), legend(label(1 "No prior computer experience") label(2) label(3 "Prior computer experience") label(4) order(1 3) rows(1)) ytitle(Output Relative to First Day) xscale(r(1(1)28)) xlabel(2(2)28)
	
	graph export "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_comp_nocomp.pdf", replace
	
	restore 
	

	
	
	
	