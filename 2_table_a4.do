/****************************************************************
****************************************************************
File:		2_table_a4.do
Purpose:	Generate Table A4: Temperature Effect on Hourly Productivity results

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/

//FIX: Results don't match table a4 in paper

use "$data/generated/hi_analysis_daily.dta", clear 
*******
	
	* average productivity per hour 
	reghdfe m_quality_output temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_quality_output if e(sample) == 1 
	outreg2 using "$output/tables/table_a4.xls", ///
		addstat("Dependent Variable Mean", r(mean)) replace ///
		label nocon nodepvar ctitle("Quality Adjusted Output (per hr)") 
	
	* average entries per hour
	reghdfe m_total_entries temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_total_entries if e(sample) == 1 
	outreg2 using "$output/tables/table_a4.xls", /// 
		addstat("Dependent Variable Mean", r(mean)) ///
		label nocon nodepvar ctitle("Total number of entries (per hr)") 
	
	* average typing time
	reghdfe m_typing_time temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_typing_time if e(sample) == 1 
	outreg2 using "$output/tables/table_a4.xls",  ///
		addstat("Dependent Variable Mean", r(mean)) ///
		label nocon nodepvar ctitle("Active Time Typing (min/hr)") 
	
	* average mistakes
	reghdfe m_mistakes_number temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ m_mistakes_number if e(sample) == 1 
	outreg2 using "$output/tables/table_a4.xls", ///
		addstat("Dependent Variable Mean", r(mean)) /// 
		label nocon nodepvar ctitle("Mistakes (per 100 entries)") 
	
	* average earnings
	reghdfe performance_earnings_hr temperature_c, absorb(pid day_in_study month#year) cluster(pid)
	summ performance_earnings_hr if e(sample) == 1 
	outreg2 using "$output/tables/table_a4.xls", ///
		addstat("Dependent Variable Mean", r(mean)) ///
		label nocon nodepvar ctitle("Performance Earnings (per hr)") 
	

