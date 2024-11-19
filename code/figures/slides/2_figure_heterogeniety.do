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
	
preserve
		local output_var m_quality_output_rel
		collapse `output_var', by(day_in_study)
		* Generate spline variables
		// 15 was chosen based on best fit, see 3_split_pick.do
		mkspline day_1 16 day_2 = day_in_study

		* Regress y on spline variables
		regress `output_var' day_1 day_2

		* Store coefficients
		scalar b0 = _b[_cons]
		scalar b1 = _b[day_1]
		scalar b2 = _b[day_2]

		* Plot without fitted regression
	twoway ///
				(scatter `output_var' day_in_study) ///
				,ytitle(Output Relative to First Day) xtitle(Day in Study) xscale(r(1(1)28)) xlabel(2(4)28) ylabel(1(1)5) yscale(r(1(1)5))  ///
				legend(off)  
		graph export "$output/figures/figure_learning.pdf", replace
	
		* Plot with fitted regression
	twoway ///
				(scatter `output_var' day_in_study) ///
				/// (qfit `output_var' day_in_study) ///
				(function yhat = b0 + b1*x, range(1 17) color(eltblue)) ///
				(function yhat = b0 + b1*16 + b2*(x - 17), range(17 28) color(eltblue)) ///
				,ytitle(Output Relative to First Day) xtitle(Day in Study) xscale(r(1(1)28)) xlabel(2(4)28) ylabel(1(1)5) yscale(r(1(1)5))  ///
				legend(off)  

		graph export "$output/figures/figure_learning_piecewise.pdf", replace
	restore

	preserve 
		collapse m_quality_output_rel, by(day_in_study computer)
		
		twoway ///
			(scatter m_quality_output_rel day_in_study if computer==0, color(eltblue))  ///
			(qfit m_quality_output_rel day_in_study if computer==0, lwidth(medium) color(eltblue))  ///
			(scatter m_quality_output_rel day_in_study if computer==1, color(navy))  ///
			(qfit m_quality_output_rel day_in_study if computer==1, color(navy)), name(test) ///
			ytitle(Output Relative to First Day) xscale(r(1(1)28)) xlabel(2(2)28) ylabel(1(1)5) ylabel(1(1)5) yscale(r(1(1)5)) ///
			legend(label(1 "No prior computer experience") label(2) label(3 "Prior computer experience") label(4) order(1 3) rows(1) size(medlarge)) ///
		
		graph export "$output/figures/figure_learning_computer.pdf", replace
	
	restore 
	

	preserve 
	
		collapse m_quality_output_rel, by(day_in_study english)
		
		twoway ///
			(scatter m_quality_output_rel day_in_study if english==0, color(eltblue))  ///
			(qfit m_quality_output_rel day_in_study if english==0, lwidth(medium) color(eltblue))  ///
			(scatter m_quality_output_rel day_in_study if english==1, color(navy))  ///
			(qfit m_quality_output_rel day_in_study if english==1, color(navy)), ///
			legend(label(1 "No English") label(2) label(3 "Speaks English") label(4) order(1 3) rows(1)) ///
			ytitle(Output Relative to First Day) xscale(r(1(1)28)) xlabel(2(2)28) ylabel(0(2)8) yscale(r(1(1)8))
		
		graph export "$output/figures/figure_learning_english.pdf", replace
	
	restore 
	

	
	
	
	

	
	
	
