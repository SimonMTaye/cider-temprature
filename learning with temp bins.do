	
	* learning figure
	
	use "$data/generated/hi_analysis_daily.dta", clear  

	* normalize productivity to day 1 
	bysort pid: gen temp = m_quality_output if day_in_study==1
	bysort pid: egen day_1_quality = max(temp)
	gen m_quality_output_rel = m_quality_output/day_1_quality
	
	* temp bins by day (so weird mix of people but should be lower bound to continued exposure)
	sum temperature_c, d
	local temp_p10 = r(p10)
	local temp_p25 = r(p25)
	local temp_p50 = r(p50)
	local temp_p75 = r(p75)
	local temp_p90 = r(p90)
	
	* p50
	gen temp_above_p50 = 1 if (temperature_c >`temp_p50' & temperature_c!=.)
	replace temp_above_p50 = 0 if (temperature_c <=`temp_p50' & temperature_c!=.)
	la var temp_above_p50 "1 if above median temp by day, 0 if below"
	
	* quartiles
	gen temp_quartile = 1 if (temperature_c <=`temp_p25' & temperature_c!=.)
	replace temp_quartile = 2 if (temperature_c >`temp_p25' & temperature_c <=`temp_p50' & temperature_c!=.)
	replace temp_quartile = 3 if (temperature_c >`temp_p50' & temperature_c <=`temp_p75' & temperature_c!=.)
	replace temp_quartile = 4 if (temperature_c >`temp_p75' & temperature_c!=.)
	la var temp_quartile "quartile bins of temp by day, 1 lowest"
	
	* p90 and p10 
	gen temp_topbottomdecile = 1 if (temperature_c >`temp_p90' & temperature_c!=.)
	replace temp_topbottomdecile = 0 if (temperature_c <=`temp_p10' & temperature_c!=.)
	la var temp_topbottomdecile "1 if top decile temp by day, 0 if bottom"
	
	* temp bins by person overall (i.e. high temps whole time or low whole time - note if just do 14 days should adjust the period which i havent' bothered with yet)
	egen tempave_pid = mean(temperature_c), by(pid)
	egen pid_tag = tag(pid)
	
	sum tempave_pid if pid_tag==1, d
	local tempave_pid_p10 = r(p10)
	local tempave_pid_p25 = r(p25)
	local tempave_pid_p50 = r(p50)
	local tempave_pid_p75 = r(p75)
	local tempave_pid_p90 = r(p90)
	
	* only for first half 
	
	egen tempave_pid_fh = mean(temperature_c) if day_in_study<15, by(pid)
	sum tempave_pid_fh if pid_tag==1, d
	local tempave_pid_fh_p10 = r(p10)
	local tempave_pid_fh_p25 = r(p25)
	local tempave_pid_fh_p50 = r(p50)
	local tempave_pid_fh_p75 = r(p75)
	local tempave_pid_fh_p90 = r(p90)
	
	* median 
	gen tempave_pid_above_p50 = 1 if (tempave_pid >`tempave_pid_p50' & tempave_pid!=.)
	replace tempave_pid_above_p50 = 0 if (tempave_pid <=`tempave_pid_p50' & tempave_pid!=.)
	la var tempave_pid_above_p50 "1 if above median temp by pid ave, 0 if below"
	
	* quartiles
	gen tempave_pid_quartile = 1 if (tempave_pid <=`tempave_pid_p25' & tempave_pid!=.)
	replace tempave_pid_quartile = 2 if (tempave_pid >`tempave_pid_p25' & tempave_pid <=`tempave_pid_p50' & tempave_pid!=.)
	replace tempave_pid_quartile = 3 if (tempave_pid >`tempave_pid_p50' & tempave_pid <=`tempave_pid_p75' & tempave_pid!=.)
	replace tempave_pid_quartile = 4 if (tempave_pid >`tempave_pid_p75' & tempave_pid!=.)
	la var tempave_pid_quartile "quartile bins of temp by pid ave, 1 lowest"
	
	
	* quartiles by first half of study only 
	gen tempave_pid_quartile_fh = 1 if (tempave_pid_fh <=`tempave_pid_fh_p25' & tempave_pid_fh!=.)
	replace tempave_pid_quartile_fh = 2 if (tempave_pid_fh >`tempave_pid_fh_p25' & tempave_pid_fh <=`tempave_pid_p50' & tempave_pid_fh!=.)
	replace tempave_pid_quartile_fh = 3 if (tempave_pid_fh >`tempave_pid_fh_p50' & tempave_pid_fh <=`tempave_pid_p75' & tempave_pid_fh!=.)
	replace tempave_pid_quartile_fh = 4 if (tempave_pid_fh >`tempave_pid_fh_p75' & tempave_pid_fh!=.)
	la var tempave_pid_quartile_fh "quartile bins of temp by pid ave first half, 1 lowest"
	
	
	
	
	
	
	* top/bottom decile 
	gen tempave_pid_topbottomdecile = 1 if (tempave_pid >`tempave_pid_p10' & tempave_pid!=.)
	replace tempave_pid_topbottomdecile = 0 if (tempave_pid <=`tempave_pid_p90' & tempave_pid!=.)
	la var temp_topbottomdecile "1 if top decile temp by pid ave, 0 if bottom"
	
	* what are averages in the bins 
	sum temperature_c if temp_quartile==1 & day<15, d
	sum temperature_c if temp_quartile==4 & day<15, d
	
	sum temperature_c if tempave_pid_quartile==1 & day<15, d
	sum temperature_c if tempave_pid_quartile==4 & day<15, d	
	


	
	* figure by day 
	
	*set scheme eop 
	
	preserve
		collapse m_quality_output_rel, by(day_in_study temp_quartile)
		*half period, top/bottom
		twoway (scatter m_quality_output_rel day_in_study if temp_quartile==1 & day<15, color(navy))  ///
		(fpfit m_quality_output_rel day_in_study if temp_quartile==1 & day<15, estopts(deg(1)) lwidth(medium) color(navy))  ///
		(scatter m_quality_output_rel day_in_study if temp_quartile==4 & day<15, color(eltblue) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15))  ///
		(fpfit m_quality_output_rel day_in_study if temp_quartile==4 & day<15, estopts(deg(1)) color(eltblue)),  ///
		legend(label(1 "Low Temperature") label(2) label(3 "High Temperature") label(4) order(1 3) rows(1)) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15)
		graph export "$output/figures/learning_quartile_half.pdf", replace
	restore
	

	
	
	* figure by pid 
	
	
	*quartiles 
	preserve
	collapse m_quality_output_rel, by(day_in_study tempave_pid_quartile)
	*half period, top/bottom
	twoway (scatter m_quality_output_rel day_in_study if tempave_pid_quartile==1 & day<15, color(navy))  ///
	(fpfit m_quality_output_rel day_in_study if tempave_pid_quartile==1 & day<15, estopts(deg(1)) lwidth(medium) color(navy))  ///
	(scatter m_quality_output_rel day_in_study if tempave_pid_quartile==4 & day<15, color(eltblue) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15))  ///
	(fpfit m_quality_output_rel day_in_study if tempave_pid_quartile==4 & day<15, estopts(deg(1)) color(eltblue)),  ///
	legend(label(1 "Low Temperature") label(2) label(3 "High Temperature") label(4) order(1 3) rows(1)) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15)
 	graph export "$output/figures/learning_quartileave_half.pdf", replace

	restore 
	
	
	
	**quartiles using fh only 
	preserve
	collapse m_quality_output_rel, by(day_in_study tempave_pid_quartile_fh)
	*half period, top/bottom
	twoway (scatter m_quality_output_rel day_in_study if tempave_pid_quartile_fh==1 & day<15, color(black))  ///
	(fpfit m_quality_output_rel day_in_study if tempave_pid_quartile_fh==1 & day<15, estopts(deg(1)) lwidth(medium) color(black))  ///
	(scatter m_quality_output_rel day_in_study if tempave_pid_quartile_fh==4 & day<15, color(cranberry) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15))  ///
	(fpfit m_quality_output_rel day_in_study if tempave_pid_quartile_fh==4 & day<15, estopts(deg(1)) color(cranberry)),  ///
	legend(label(1 "Low Temperature") label(2) label(3 "High Temperature") label(4) order(1 3) rows(1)) ytitle(Output Relative to First Day) xscale(r(1(1)15)) xlabel(2(2)15)
 	graph export "$output/figures/learning_quartileave_half_1.pdf", replace

	
	

//	
//	
