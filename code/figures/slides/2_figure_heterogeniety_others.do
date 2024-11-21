/****************************************************************
****************************************************************
File:		2_figure_1
Purpose:	Generate Figure 1: learning results

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
	* learning figure
	

clear all 
use "$data/generated/hi_analysis_daily.dta", clear 
	
	*bysort pid: gen temp_output = m_quality_output_rel if day_in_study==1
	*bysort pid: egen day_1_quality = max(temp_output)
	*gen m_quality_output_rel_rel = m_quality_output/day_1_quality

 		foreach split_var of varlist edu_m age_m {
		preserve 
			collapse m_quality_output_rel, by(day_in_study `split_var')
			
			twoway ///
				(scatter m_quality_output_rel day_in_study if `split_var'==0, color(eltblue))  ///
				(qfit m_quality_output_rel day_in_study if `split_var'==0, lwidth(medium) color(eltblue))  ///
				(scatter m_quality_output_rel day_in_study if `split_var'==1, color(navy))  ///
				(qfit m_quality_output_rel day_in_study if `split_var'==1, color(navy)),  ///
				ytitle(Output Relative to First Day) xscale(r(1(1)28)) xlabel(2(2)28) ylabel(1(1)5) ylabel(1(1)5) yscale(r(1(1)5)) ///
				legend(label(1 "Below median `split_var'") label(2) label(3 "Above median `split_var'") label(4) order(1 3) rows(1) size(medlarge)) ///
			
			graph export "$output/figures/figure_learning_`split_var'.pdf", replace
		
		restore 
	}
	

	
	
	
	

	
	
	
