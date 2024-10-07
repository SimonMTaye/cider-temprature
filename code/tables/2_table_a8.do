/****************************************************************
****************************************************************
File:		2_table_a8.do
Purpose:	Generate Table A8: Evolution of productivity

Author:		Isadora Frankenthal
Modified By:	Simon Taye
****************************************************************
****************************************************************/
clear all 
use "$data/generated/hi_analysis_daily.dta", clear 
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

	label var day_in_study		"Days in Study"
	label var day_in_study_beg	"Days in Study * First Half of the Study"
	label var day_in_study_end	"Days in Study * Second Half of the Study"

	label var day1to7	"Days in Study * Study Week 1"
	label var day8to14	"Days in Study * Study Week 2"
	label var day15to21	"Days in Study * Study Week 3"
	label var day22to28	"Days in Study * Study Week 4"

	** proof of learning table 
	
	reghdfe m_quality_output day_in_study, absorb(pid month#year) cluster(pid) 
		summ m_quality_output if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
		eststo

	reghdfe m_quality_output day_in_study_beg day_in_study_end, absorb(pid month#year) cluster(pid) 
		summ m_quality_output if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
		eststo

	
	reghdfe m_quality_output day1to7 day8to14 day15to21 day22to28, absorb(pid month#year) cluster(pid) 
		summ m_quality_output if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
		eststo

	#delimit ;
	esttab * using "$output/tables/table_a8.tex",  replace
		$esttab_opts nomtitles
		scalars("mean Dependent Variable Mean"  "r2 R-squared" "num_obs Observations")
		mgroups("Dependent Variable is Average Quality Adjusted Output (per hour)",
			pattern(1 0 0) 
			prefix(\multicolumn{@span}{c}{) suffix(}) 
			span erepeat(\cmidrule(lr){@span})) ; 

	#delimit cr;
