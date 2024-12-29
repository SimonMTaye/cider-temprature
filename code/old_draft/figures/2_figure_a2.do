/****************************************************************
****************************************************************
File:		2_figure_a2
Purpose:	Generate Figure A2

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear 
	
	* create temperature bins
	xtile temp_q = temperature_c, nq(4)
	gen bin1 = 1 if temp_q==1
	replace bin1=0 if bin1==. & temperature_c!=. 
	
	gen bin2 = 1 if temp_q==2
	replace bin2=0 if bin2==. & temperature_c!=. 
	
	gen bin3 = 1 if temp_q==3
	replace bin3=0 if bin3==. & temperature_c!=. 
	
	gen bin4 = 1 if temp_q==4
	replace bin4=0 if bin4==. & temperature_c!=. 
	
	
	reghdfe m_quality_output bin2 bin3 bin4, absorb(pid day_in_study month#year) cluster(pid)
	
	* store regression coefficents in variables for plotting
	gen beta_2 = .
	replace beta_2 = 0 if _n==1
	replace beta_2 = _b[bin2] if _n==2
	replace beta_2 = _b[bin3] if _n==3
	replace beta_2 = _b[bin4] if _n==4
	
//
	gen se_2 = .
	replace se_2 = 0 if _n==1
	replace se_2 = _se[bin2] if _n==2
	replace se_2 = _se[bin3] if _n==3
	replace se_2 = _se[bin4] if _n==4

//	
	* confidence interavls
	gen ci_up_2 = beta_2 + 1.65*se_2
	gen ci_down_2 = beta_2 - 1.65*se_2
//	
	* label temperature bins
	gen temps_2 = ""
	replace temps_2 = "Under 27" if _n==1
	replace temps_2 = "27-29.75" if _n==2
	replace temps_2 = "29.75-33.45" if _n==3
	replace temps_2 = "Above 33.45" if _n==4
	
//	
	gen x_2 = _n if _n<5
	graph bar beta_2, over(temps_2)
	twoway	(rcap ci_up_2 ci_down_2 x_2, color(emerald)) ///
		(scatter beta_2 x_2, mcolor(emerald)), ///  
		ytitle("Coefficient Estimate") legend(off) yline(0,lcolor(black) lpattern(dash)) /// 
		xtitle(" ") xscale(r(0.7 4.2) titlegap(4)) xlabel(1 "Under 27°C" 2 "27-29.75°C" 3 "29.75-33.45°C" 4 "Above 33.45°C") /// 
		xtitle("Temperature Quartiles") yscale(r(-200(50)50) titlegap(-1.5)) ylabel(-200(50)50) plotregion(margin(right)) 

	graph export "$output/figures/figure_a2.pdf", replace
	
	
	

