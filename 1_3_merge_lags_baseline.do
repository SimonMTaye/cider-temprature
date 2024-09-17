/****************************************************************
****************************************************************
File:		1_3_merge_lags_baseline
Purpose:	Generate lagged temperatue variables and merge in baseline data with temp and
		productivity data

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/

use "$data/generated/hi_hourly_temp_NOAA_indiatime.dta", clear 
	
	
***** Generate tempratue lag and high point variables for different times of the day

	egen temp_1 = mean(temperature_c) if time_india >= 600 & time_india<=2300, by (day month year)
	egen temp_2 = mean(temperature_c) if time_india >= 700 & time_india<=2300, by (day month year)
	egen temp_3 = mean(temperature_c) if time_india >= 800 & time_india<=2300, by (day month year)
	egen temp_4 = mean(temperature_c) if time_india >= 900 & time_india<=2300, by (day month year)
	egen temp_5 = mean(temperature_c) if time_india >= 1000 & time_india<=2300, by (day month year)
	egen temp_6 = mean(temperature_c) if time_india >= 600 & time_india<=2200, by (day month year)
	egen temp_7 = mean(temperature_c) if time_india >= 600 & time_india<=2100, by (day month year)
	egen temp_8 = mean(temperature_c) if time_india >= 600 & time_india<=2000, by (day month year)
	egen temp_9 = mean(temperature_c) if time_india >= 600 & time_india<=1900, by (day month year)
	egen temp_10 = mean(temperature_c) if time_india >= 700 & time_india<=1900, by (day month year)
	egen temp_11 = mean(temperature_c) if time_india >= 800 & time_india<=1900, by (day month year)
	egen temp_12 = mean(temperature_c) if time_india >= 900 & time_india<=1900, by (day month year)
	egen temp_13 = mean(temperature_c) if time_india >= 1000 & time_india<=1900, by (day month year)
	
	egen hi_1 = mean(heat_index) if time_india >= 600 & time_india<=2300, by (day month year)
	egen hi_2 = mean(heat_index) if time_india >= 700 & time_india<=2300, by (day month year)
	egen hi_3 = mean(heat_index) if time_india >= 800 & time_india<=2300, by (day month year)
	egen hi_4 = mean(heat_index) if time_india >= 900 & time_india<=2300, by (day month year)
	egen hi_5 = mean(heat_index) if time_india >= 1000 & time_india<=2300, by (day month year)
	egen hi_6= mean(heat_index) if time_india >= 600 & time_india<=2200, by (day month year)
	egen hi_7 = mean(heat_index) if time_india >= 600 & time_india<=2100, by (day month year)
	egen hi_8 = mean(heat_index) if time_india >= 600 & time_india<=2000, by (day month year)
	egen hi_9 = mean(heat_index) if time_india >= 600 & time_india<=1900, by (day month year)
	egen hi_10 = mean(heat_index) if time_india >= 700 & time_india<=1900, by (day month year)
	egen hi_11 = mean(heat_index) if time_india >= 800 & time_india<=1900, by (day month year)
	egen hi_12 = mean(heat_index) if time_india >= 900 & time_india<=1900, by (day month year)
	egen hi_13 = mean(heat_index) if time_india >= 1000 & time_india<=1900, by (day month year)
	
	egen temp_short = mean(temperature_c) if time_india >=1100 & time_india<=1600, by (day month year)
	egen hi_short = mean(heat_index) if time_india >=1100 & time_india<=1600, by (day month year)
	
	
	collapse temperature_c temp_* hi* humidity, by(day month year)
	egen date = group(year month day)
	sort date
	
	* create lags
	foreach var in temperature_c temp_1 temp_2 temp_3 temp_4 temp_5 temp_6 temp_7 temp_8 temp_9 temp_10 temp_11 temp_12 temp_13 hi_1 hi_2 hi_3 hi_4 hi_5 hi_6 hi_7 hi_8 hi_9 hi_10 hi_11 hi_12 hi_13 {
	
		gen l1_`var' = `var'[_n - 1]
		gen l2_`var' = `var'[_n - 2]
		gen l3_`var' = `var'[_n - 3]
		gen l4_`var' = `var'[_n - 4]
		gen l5_`var' = `var'[_n - 5]
		gen l6_`var' = `var'[_n - 6]
		gen l7_`var' = `var'[_n - 7]
		gen l8_`var' = `var'[_n - 8]
		gen l9_`var' = `var'[_n - 9]
		gen l10_`var' = `var'[_n - 10]
		gen l11_`var' = `var'[_n - 11]
		gen l12_`var' = `var'[_n - 12]
		
		gen ld1_`var' = `var'[_n + 1]
		gen ld2_`var' = `var'[_n + 2]
		gen ld3_`var' = `var'[_n + 3]
		gen ld4_`var' = `var'[_n + 4]
		gen ld5_`var' = `var'[_n + 5]
		gen ld6_`var' = `var'[_n + 6]
		gen ld7_`var' = `var'[_n + 7]
		gen ld8_`var' = `var'[_n + 8]
		gen ld9_`var' = `var'[_n + 9]
		gen ld10_`var' = `var'[_n + 10]
	
	}

	tempfile lags
save `lags'


local times hourly daily
foreach time of local times {
	use "$data/generated/hi_analysis_`time'.dta", clear

	****** Merge lagged temperatue data with productivity data

		merge m:1 day month year using "`lags'"
		drop if _merge==2
		drop _merge

		* merge baseline data
		
		merge m:1 pid using "$data/raw/baseline_cleaned.dta"
		drop _merge 
		
		* used for balance table a11
		gen english = a15
		gen computer = a23
		* a18 what is 3 x 9 
		gen threetimesnine = a18 
		replace threetimesnine = 0 if threetimesnine!=1

		
		foreach var in temp_1 temp_2 temp_3 temp_4 temp_5 temp_6 temp_7 temp_8 temp_9 temp_10 temp_11 temp_12 temp_13 {
			
			gen `var'_workday = `var'
			replace `var'_workday = temp_short if day_type==1
			
		}
		
		foreach var in hi_1 hi_2 hi_3 hi_4 hi_5 hi_6 hi_7 hi_8 hi_9 hi_10 hi_11 hi_12 hi_13 {
			
			gen `var'_workday = `var'
			replace `var'_workday = hi_short if day_type==1
			
		}
		
		gen earnings = performance_earnings + attendance_earnings
		gen performance_earnings_hr = performance_earnings/count_hours
		
	save "$data/generated/hi_analysis_`time'.dta", replace
}
