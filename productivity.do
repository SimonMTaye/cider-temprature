* daily and hourly productivity 

	* productivity at hourly level
	
	use "$dir/01. Raw Data/Productivity/hi_analysis_hourly.dta", clear 
	
	
	// productivity table at hourly level 
	
	cd "/Users/isadorafrankenthal/Dropbox/Temperature/Data/2. Main Study" 
	set scheme eop

	
	reghdfe quality_output temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
	summ quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_hourly.xls", addstat("mean", r(mean), "sd", r(sd)) replace 
	
	reghdfe total_entries temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
	summ total_entries if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_hourly.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe typing_time temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
	summ typing_time if e(sample) == 1
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_hourly.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe mistakes_number temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
	summ mistakes_number if e(sample) == 1
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_hourly.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe performance_earnings temperature_c, absorb(pid day_in_study time_india month#year) cluster(pid)
	summ performance_earnings if e(sample) == 1
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_hourly.xls", addstat("mean", r(mean), "sd", r(sd))


	
	
	// productivity at daily level 
	
	use "$dir/01. Raw Data/Productivity/hi_analysis_daily.dta", clear 
	
	
	* average productivity per hour 

	reghdfe m_quality_output temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av.xls", addstat("mean", r(mean), "sd", r(sd)) replace
	
	reghdfe m_total_entries temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_total_entries if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe m_typing_time temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_typing_time if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe m_mistakes_number temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_mistakes_number if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe performance_earnings_hr temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ performance_earnings_hr if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av.xls", addstat("mean", r(mean), "sd", r(sd))
	
	
	* average productivity per hour with pollution 

	reghdfe m_quality_output temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_pollution.xls", addstat("mean", r(mean), "sd", r(sd)) replace
	
	reghdfe m_total_entries temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ m_total_entries if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_pollution.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe m_typing_time temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ m_typing_time if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_pollution.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe m_mistakes_number temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ m_mistakes_number if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_pollution.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe performance_earnings_hr temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ performance_earnings_hr if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_pollution.xls", addstat("mean", r(mean), "sd", r(sd))
	
	
	
	
	* sum 
	
	reghdfe quality_output temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ quality_output if e(sample) == 1 
 	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_sum.xls", addstat("mean", r(mean), "sd", r(sd)) replace
	
	reghdfe total_entries temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ total_entries if e(sample) == 1 
 	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_sum.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe typing_time temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ typing_time if e(sample) == 1 
 	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_sum.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe mistakes_number temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ mistakes_number if e(sample) == 1 
 	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_sum.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe performance_earnings temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ performance_earnings if e(sample) == 1 
 	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_sum.xls", addstat("mean", r(mean), "sd", r(sd))
	
	
	
	
	* HI average productivity per hour 

	reghdfe m_quality_output heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_hi.xls", addstat("mean", r(mean), "sd", r(sd)) replace
	
	reghdfe m_total_entries heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ m_total_entries if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_hi.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe m_typing_time heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ m_typing_time if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_hi.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe m_mistakes_number heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ m_mistakes_number if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_hi.xls", addstat("mean", r(mean), "sd", r(sd))
	
	reghdfe performance_earnings_hr heat_index, absorb(pid day_in_study month#year) cluster(pid)
	summ performance_earnings_hr if e(sample) == 1 
	outreg2 using "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/prod_daily_av_hi.xls", addstat("mean", r(mean), "sd", r(sd))
	

	
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
	gen ci_up_2 = beta_2 + 1.65*se_2
	gen ci_down_2 = beta_2 - 1.65*se_2
//	
	gen temps_2 = ""
	replace temps_2 = "Under 27" if _n==1
	replace temps_2 = "27-29.75" if _n==2
	replace temps_2 = "29.75-33.45" if _n==3
	replace temps_2 = "Above 33.45" if _n==4
	
//	
	gen x_2 = _n if _n<5
	graph bar beta_2, over(temps_2)
	twoway (rcap ci_up_2 ci_down_2 x_2, color(emerald))(scatter beta_2 x_2, mcolor(emerald)) , ytitle("Coefficient Estimate") legend(off) yline(0,lcolor(black) lpattern(dash)) xtitle(" ") xscale(r(0.7 4.2) titlegap(4)) xlabel(1 "Under 27°C" 2 "27-29.75°C" 3 "29.75-33.45°C" 4 "Above 33.45°C") xtitle("Temperature Quartiles") yscale(r(-110(50)100) titlegap(-1.5)) ylabel(-100(50)100) plotregion(margin(right)) 
	graph export "$dir/05. Analysis/01. Code/new results 2023 2024/clean code + results jun 2024/results/formatted/nonlinear_av_hourly_day_temp.pdf", replace
	
	
	

