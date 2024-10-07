* learning with growth rates 

	clear all 
	global dir "/Users/isadorafrankenthal/Dropbox/Temperature/Data/2. Main Study" 

	use "$dir/01. Raw Data/Productivity/hi_analysis_daily.dta", clear 
	
	xtset pid day_in_study 
	
	egen max_a23 = max(a23), by(pid)
	gen comp = 0 if max_a23 == 0 
	replace comp = 1 if max_a23 == 1
	
// 	gen one = 1 
// 	egen sum_one = sum(one), by(pid)
// 	drop if sum_one < 21
	

	// define period to be every two days 
	
	sort pid day_in_study 
	
	gen two_days = 1 if inrange(day_in_study, 1, 2)
	replace two_days = 2 if inrange(day_in_study, 3, 4)
	replace two_days = 3 if inrange(day_in_study, 5, 6)
	replace two_days = 4 if inrange(day_in_study, 7, 8)
	replace two_days = 5 if inrange(day_in_study, 9, 10)
	replace two_days = 6 if inrange(day_in_study, 11, 12)
	replace two_days = 7 if inrange(day_in_study, 13, 14)
	replace two_days = 8 if inrange(day_in_study, 15, 16)
	replace two_days = 9 if inrange(day_in_study, 17, 18)
	replace two_days = 10 if inrange(day_in_study, 19, 20)
	replace two_days = 11 if inrange(day_in_study, 21, 22)
	replace two_days = 12 if inrange(day_in_study, 23, 24)
	replace two_days = 13 if inrange(day_in_study, 25, 26)
	replace two_days = 14 if inrange(day_in_study, 27, 28)
	
	
	gen one = 1 if day_in_study<15
	egen count = sum(one), by (pid)
	
	gen absents = 1 if count<12 
	egen max_absents = max(absents), by(pid)
	
	drop if max_absents==1
	
	
	* mean output/temp every two days 
	egen quality_output_two_days = mean(m_quality_output), by(pid two_days)
	egen temp_c_two_days = mean(temperature_c), by(pid two_days)
	
	
	
	* lags 
	
	gen l1_temp_c_two_days = (l1_temperature_c + l2_temperature_c)/2
	gen l2_temp_c_two_days = (l3_temperature_c + l4_temperature_c)/2
	gen l3_temp_c_two_days = (l5_temperature_c + l6_temperature_c)/2
	gen l4_temp_c_two_days = (l7_temperature_c + l8_temperature_c)/2
	gen l5_temp_c_two_days = (l9_temperature_c + l10_temperature_c)/2
	
	* leads 
	
	gen ld1_temp_c_two_days = (ld1_temperature_c + ld2_temperature_c)/2
	gen ld2_temp_c_two_days = (ld3_temperature_c + ld4_temperature_c)/2
	gen ld3_temp_c_two_days = (ld5_temperature_c + ld6_temperature_c)/2
	gen ld4_temp_c_two_days = (ld7_temperature_c + ld8_temperature_c)/2
	gen ld5_temp_c_two_days = (ld9_temperature_c + ld10_temperature_c)/2
	
	
	* dummy for initial days when lags are not in the study period
	gen dummy2 = 0 if two_days<3
	replace dummy2 = 1 if dummy2==.
	gen dummy3 = 0 if two_days<4
	replace dummy3=1 if dummy3==.
	gen dummy4=0 if two_days<5
	replace dummy4=1 if dummy4==.
	gen dummy5=0 if  two_days<6
	replace dummy5=1 if dummy5==.
	
	replace computer = 0 if a24==1 

	
	* collapse at two-day level
	
// 	preserve 
	
	collapse quality_output_two_days temp_c_two_days l* hi* (firstnm) a23 comp computer english month year dummy*, by(pid two_days)
	
	sort pid two_days
	
	* gen growth rate 
	
	gen diff_quality_output_two_days = quality_output_two_days - quality_output_two_days[_n-1]
	replace diff_quality_output_two_days=. if two_days==1
	gen growth_quality_output_two_days = diff_quality_output_two_days/quality_output_two_days[_n-1]
	
	
	*** main table *** 
	
	xtset pid two_days
	
	reghdfe growth_quality_output_two_days temp_c_two_days if two_days<8, absorb(pid two_days month#year) cluster(pid)
	
	reghdfe growth_quality_output_two_days temp_c_two_days l.growth_quality_output_two_days if two_days<8, absorb(pid two_days month#year) cluster(pid)
	
	reghdfe growth_quality_output_two_days temp_c_two_days l.growth_quality_output_two_days if two_days<8 & computer==0, absorb(pid two_days month#year) cluster(pid)
	
	reghdfe growth_quality_output_two_days temp_c_two_days l.growth_quality_output_two_days if two_days<8 & computer==1, absorb(pid two_days month#year) cluster(pid)
	
		*** 
	
	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days if two_days>2 & two_days<8, absorb(pid two_days month#year) cluster(pid)
	
	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
	
	
	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & two_days<8, absorb(pid two_days month#year) cluster(pid)
	
	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
	
	
	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & two_days<8 & computer==0, absorb(pid two_days month#year) cluster(pid)
	
	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
	
	
	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & two_days<8 & computer==1, absorb(pid two_days month#year) cluster(pid)
	
	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
	
		
		
		
		
	* leads // just sum of coefficients is enough to display 
	
	
	reghdfe growth_quality_output_two_days temp_c_two_days ld1_temp_c_two_days ld2_temp_c_two_days ld3_temp_c_two_days if two_days>2 & two_days<8, absorb(pid two_days month#year) cluster(pid)
	
	di _b[temp_c_two_days] + _b[ld1_temp_c_two_days] + _b[ld2_temp_c_two_days] + _b[ld3_temp_c_two_days]
	test _b[temp_c_two_days] + _b[ld1_temp_c_two_days] + _b[ld2_temp_c_two_days] + _b[ld3_temp_c_two_days] = 0 
	
	
	reghdfe growth_quality_output_two_days temp_c_two_days ld1_temp_c_two_days ld2_temp_c_two_days ld3_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & two_days<8, absorb(pid two_days month#year) cluster(pid)
	
	di _b[temp_c_two_days] + _b[ld1_temp_c_two_days] + _b[ld2_temp_c_two_days] + _b[ld3_temp_c_two_days]
	test _b[temp_c_two_days] + _b[ld1_temp_c_two_days] + _b[ld2_temp_c_two_days] + _b[ld3_temp_c_two_days] = 0 
	
	
	reghdfe growth_quality_output_two_days temp_c_two_days ld1_temp_c_two_days ld2_temp_c_two_days ld3_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & two_days<8 & computer==0, absorb(pid two_days month#year) cluster(pid)
	
	di _b[temp_c_two_days] + _b[ld1_temp_c_two_days] + _b[ld2_temp_c_two_days] + _b[ld3_temp_c_two_days]
	test _b[temp_c_two_days] + _b[ld1_temp_c_two_days] + _b[ld2_temp_c_two_days] + _b[ld3_temp_c_two_days] = 0 
	
	
	reghdfe growth_quality_output_two_days temp_c_two_days ld1_temp_c_two_days ld2_temp_c_two_days ld3_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & two_days<8 & computer==1, absorb(pid two_days month#year) cluster(pid)
	
	di _b[temp_c_two_days] + _b[ld1_temp_c_two_days] + _b[ld2_temp_c_two_days] + _b[ld3_temp_c_two_days]
	test _b[temp_c_two_days] + _b[ld1_temp_c_two_days] + _b[ld2_temp_c_two_days] + _b[ld3_temp_c_two_days] = 0 
	
		
	
	
//	
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days if two_days<8, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days if two_days>1 & two_days<8, absorb(pid two_days month#year) cluster(pid)
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] 
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] = 0 
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days if two_days>2 & two_days<8, absorb(pid two_days month#year) cluster(pid)
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] 
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] = 0 
//	
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days if two_days>3 & two_days<8, absorb(pid two_days month#year) cluster(pid)
//	
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
//	
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l4_temp_c_two_days if two_days>4 & two_days<8, absorb(pid two_days month#year) cluster(pid)
//	
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
//	
//	
//	
//	
//	
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l.growth_quality_output_two_days if two_days<8, absorb(pid two_days month#year) cluster(pid)
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l.growth_quality_output_two_days if two_days>1 & two_days<8, absorb(pid two_days month#year) cluster(pid)
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] 
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] = 0
//	
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & two_days<8, absorb(pid two_days month#year) cluster(pid)
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] 
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] = 0 
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l.growth_quality_output_two_days if two_days>3 & two_days<8, absorb(pid two_days month#year) cluster(pid)
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
//	
//	
	
//	
// 	* computer, no computer 
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l.growth_quality_output_two_days if two_days<8 & computer==0, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l.growth_quality_output_two_days if two_days<8 & computer==1, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l.growth_quality_output_two_days if two_days>1 & two_days<8 & computer==0, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l.growth_quality_output_two_days if two_days>1 & two_days<8 & computer==1, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & two_days<8 & computer==0, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & two_days<8 & computer==1, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l.growth_quality_output_two_days if two_days>3 & two_days<8 & computer==0, absorb(pid two_days month#year) cluster(pid)
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l.growth_quality_output_two_days if two_days>3 & two_days<8 & computer==1, absorb(pid two_days month#year) cluster(pid)
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
//	
//	
//	
//	
//	
//	
	
	
// 	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/learning_growth_rates.xls", replace 

// * appendix table doing for whole sample 
//
// 	xtset pid two_days
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l.growth_quality_output_two_days, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l.growth_quality_output_two_days if computer==0, absorb(pid two_days month#year) cluster(pid)
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l.growth_quality_output_two_days if computer==1, absorb(pid two_days month#year) cluster(pid)
//	
// 		*** 
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days if two_days>2, absorb(pid two_days month#year) cluster(pid)
//	
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l.growth_quality_output_two_days if two_days>2, absorb(pid two_days month#year) cluster(pid)
//	
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & computer==0, absorb(pid two_days month#year) cluster(pid)
//	
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
//	
//	
// 	reghdfe growth_quality_output_two_days temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days l.growth_quality_output_two_days if two_days>2 & computer==1, absorb(pid two_days month#year) cluster(pid)
//	
// 	di _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
// 	test _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days] = 0 
//	
//		
//	

	
