/****************************************************************
****************************************************************
File:		1_5_intermediate_vars
Purpose:	Generate intermediate vars used by various figures and tables

Author:		Isadora Frankenthal

Modified By:	Simon Taye
Note:		Adapated from the file originally called 'learning with temp bins.do'
****************************************************************
****************************************************************/
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
	


save "$data/generated/hi_analysis_daily.dta", replace
