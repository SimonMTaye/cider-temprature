/****************************************************************
****************************************************************
File:		2_table_a2.do
Purpose:	Generate Table AX: Temperature Effect on Hourly Avg Productivity results w/ Pollution


NOTE: Not sure which table in the paper it corresponds to

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/

//INFO: Could not find matching table

clear all
use "$data/generated/hi_analysis_daily.dta", clear 
*******
	label var temperature_c "Temperature (Celcius)"
	label var PM25		"PM 2.5"
	
	* average productivity per hour 
	reghdfe m_quality_output temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$output/tables/table_a2.xls", ///
		addstat("Dependent Variable Mean", r(mean)) replace ///
		label nocon nodepvar ctitle("Quality Adjusted Output (per hr)") 
	
	* average entries per hour
	reghdfe m_total_entries temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ m_total_entries if e(sample) == 1 
	outreg2 using "$output/tables/table_a2.xls", /// 
		addstat("Dependent Variable Mean", r(mean)) ///
		label nocon nodepvar ctitle("Total number of entries (per hr)") 
	
	* average typing time
	reghdfe m_typing_time temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ m_typing_time if e(sample) == 1 
	outreg2 using "$output/tables/table_a2.xls",  ///
		addstat("Dependent Variable Mean", r(mean)) ///
		label nocon nodepvar ctitle("Active Time Typing (min/hr)") 
	
	* average mistakes
	reghdfe m_mistakes_number temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ m_mistakes_number if e(sample) == 1 
	outreg2 using "$output/tables/table_a2.xls", ///
		addstat("Dependent Variable Mean", r(mean)) /// 
		label nocon nodepvar ctitle("Mistakes (per 100 entries)") 
	
	* average earnings
	reghdfe performance_earnings temperature_c PM25, absorb(pid day_in_study month#year) cluster(pid)
	summ performance_earnings if e(sample) == 1 
	outreg2 using "$output/tables/table_a2.xls", ///
		addstat("Dependent Variable Mean", r(mean)) ///
		label nocon nodepvar ctitle("Performance Earnings (per hr)") 
	
