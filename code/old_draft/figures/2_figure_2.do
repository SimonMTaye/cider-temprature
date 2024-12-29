/****************************************************************
****************************************************************
File:		2_figure_2
Purpose:	Generate Figure 1: learning results

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear  
	* figure by day 
	
	*set scheme eop 
	
	preserve
		collapse m_quality_output_rel, by(day_in_study temp_quartile)
		*half period, top/bottom
		twoway (scatter m_quality_output_rel day_in_study if temp_quartile==1 & day_in_study<15, color(navy))  ///
		(fpfit m_quality_output_rel day_in_study if temp_quartile==1 & day_in_study<15, estopts(deg(1)) lwidth(medium) color(navy))  ///
		(scatter m_quality_output_rel day_in_study if temp_quartile==4 & day_in_study<15, color(eltblue) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15))  ///
		(fpfit m_quality_output_rel day_in_study if temp_quartile==4 & day_in_study<15, estopts(deg(1)) color(eltblue)),  ///
		legend(label(1 "Low Temperature") label(2) label(3 "High Temperature") label(4) order(1 3) rows(1)) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15)
		graph export "$output/figures/figure_2_a.pdf", replace
	restore
	

	
	
	* figure by pid 
	
	
	*quartiles 
	preserve
		collapse m_quality_output_rel, by(day_in_study tempave_pid_quartile)
		*half period, top/bottom
		twoway	(scatter m_quality_output_rel day_in_study if tempave_pid_quartile==1 & day_in_study<15, color(navy))  ///
			(fpfit m_quality_output_rel day_in_study if tempave_pid_quartile==1 & day_in_study<15, estopts(deg(1)) lwidth(medium) color(navy))  ///
			(scatter m_quality_output_rel day_in_study if tempave_pid_quartile==4 & day_in_study<15, color(eltblue) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15))  ///
			(fpfit m_quality_output_rel day_in_study if tempave_pid_quartile==4 & day_in_study<15, estopts(deg(1)) color(eltblue)),  ///
			legend(label(1 "Low Temperature") label(2) label(3 "High Temperature") label(4) order(1 3) rows(1)) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15)
			graph export "$output/figures/figure_2_b.pdf", replace

	restore 
	

	/** The code below is here to check; Note that there is no corresponding figure in the paper
	**quartiles using fh only 
	preserve
		collapse m_quality_output_rel, by(day_in_study tempave_pid_quartile_fh)
		*half period, top/bottom
		twoway	(scatter m_quality_output_rel day_in_study if tempave_pid_quartile_fh==1 & day<15, color(black))  ///
			(fpfit m_quality_output_rel day_in_study if tempave_pid_quartile_fh==1 & day<15, estopts(deg(1)) lwidth(medium) color(black))  ///
			(scatter m_quality_output_rel day_in_study if tempave_pid_quartile_fh==4 & day<15, color(cranberry) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15))  ///
			(fpfit m_quality_output_rel day_in_study if tempave_pid_quartile_fh==4 & day<15, estopts(deg(1)) color(cranberry)),  ///
			legend(label(1 "Low Temperature") label(2) label(3 "High Temperature") label(4) order(1 3) rows(1)) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15)
			graph export "$output/figures/learning_quartileave_half_1.pdf", replace

	*/
		
	


