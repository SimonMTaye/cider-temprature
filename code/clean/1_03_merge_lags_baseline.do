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

 	// Subset to workday
	keep if time_india >= 900 & time_india<=1900

	collapse (mean) workday_temperature_c=temperature_c humidity, by(day month year)

	egen date = group(year month day)
	sort date
	
	* create lags
		local var workday_temperature_c

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

    label var workday_temperature_c "Temperature ($^{\circ}C$)"

save "$data/generated/temperatue_lags.dta", replace


use "$data/generated/hi_analysis_daily.dta", clear

	****** Merge lagged temperatue data with productivity data

		merge m:1 day month year using "$data/generated/temperatue_lags.dta"
		drop if _merge==2
		drop _merge
		* merge baseline data
		
		merge m:1 pid using "$data/raw/baseline_cleaned.dta"
		drop _merge 

		gen earnings = performance_earnings + attendance_earnings
		gen performance_earnings_hr = performance_earnings/count_hours

  	preserve
			// Generate a dataset with lagged mean observed temperature
			egen mean_temperature_c = mean(temperature_c), by(day_in_study)
			keep mean_temperature_c day_in_study
			duplicates drop

		
			tset day_in_study
			forvalues i = 1/10 {
				gen l`i'_mean_temperature_c = L`i'.mean_temperature_c
			}
			tempfile mean_lags
			save `mean_lags', replace
		restore
		
		
		merge m:1 day_in_study using `mean_lags', nogen

  	// Generate time in office lags
		xtset pid day_in_study
		forvalues i=1/10 {
				gen l`i'_temperature_c = L`i'.temperature_c
				gen ld`i'_temperature_c = F`i'.temperature_c

				// Replace missing lags with average experienced temperature
				replace l`i'_temperature_c = l`i'_mean_temperature_c if missing(l`i'_temperature_c)
				// Replace lag in the first few days with work_day_lags
				replace l`i'_temperature_c = l`i'_workday_temperature_c if missing(l`i'_temperature_c) & day_in_study <= `i'

    		
				gen l`i'_heat_index = L`i'.heat_index
				gen ld`i'_heat_index = F`i'.heat_index

				label var l`i'_temperature_c "Lag `i' of Temperature"
				label var ld`i'_temperature_c "Lead `i' of Temperature"

				label var l`i'_heat_index "Lag `i' of Heat Index"
				label var ld`i'_heat_index "Lead `i' of Heat Index"

				label var l`i'_workday_temperature_c "Lag `i' of Temperature"
				label var ld`i'_workday_temperature_c "Lead `i' of Temperature"

		}
		
save "$data/generated/hi_analysis_daily.dta", replace
