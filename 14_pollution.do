/****************************************************************
****************************************************************
File:		14_pollution
Purpose:	Merge in pollution data

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
****** Merge in pollution data
import excel "$data/raw/pollution_added.xls", sheet("Sheet1") firstrow clear

	collapse PM25, by(day month year)
 
	tempfile pollution
save `pollution'
 
use "$data/generated/hi_analysis_daily.dta", clear
	
	merge m:1 day month year using "`pollution'"
	drop if _merge==2 
	drop _merge 
	
save "$data/generated/hi_analysis_daily.dta", replace
 
 
 
 
 
 
 
 
 
 
 
	
	
	
	
