	
	* Absenteeism & Hours at Work * 
	
*** Old code that generate hours of work.dta	
	use "$data/raw/analysis_base.dta", clear
	
	  keep if dropout_category!=2
	
    * Generate date variables
    gen year = year(date)
    gen month = month(date)
    gen day = day(date)
	
    * Convert to string
    gen month_ = string(month, "%02.0f")
    drop month
    rename month_ month
    
    gen day_ = string(day, "%02.0f")
    drop day
    rename day_ day 
	
    destring day, replace 
    destring month, replace
    destring year, replace 
    destring time, replace 
    drop date 

	
    merge 1:1 pid day_in_study using "$data/checkin_checkout.dta"
    drop if _merge==2
    drop _merge
    
    egen date = group(year month day)
    
    save "$data/hours_of_work.dta", replace 
	

	* Absenteeism, checkin / checkout time 
	
*** Newer abseentism code that generate the tables
	clear all 
	use "$data/hours_of_work.dta", clear
	
	* merge day type 
	
	preserve 
    use "$data/analysis_hourly.dta", clear
    collapse (firstnm) day_type salience (mean) fraction_high, by (pid day_in_study)
    tempfile daytype
    save `daytype'
	restore 
	
	merge 1:1 pid day_in_study using "`daytype'"
	drop _merge
	
	* merge with temp data
	
	preserve
    use "$dir/01. Raw Data/Temperature/hourly_temp_NOAA_indiatime.dta", clear 
    keep if time_india>800 & time_india<2000
    collapse (mean) temperature_c humidity rainfall, by (day year month)
    tempfile temp
	save `temp'
	
	restore 
	
	merge m:1 day month year using "`temp'"
	drop if _merge==2
	drop _merge
	
	gen tempc_round = round(temperature_c)
	
	xtset pid day_in_study
	
	xtile temp_qtile = temperature_c, nq(4)
	
	gen high_temp = 0 
	replace high_temp = 1 if temp_qtile==4
	gen medium_temp = 0 
	replace medium_temp = 1 if temp_qtile==3 
	gen lower_temp = 0 
	replace lower_temp = 1 if temp_qtile==2
	
	* merge temperature lags 
	
	preserve 
	use "$dir/01. Raw Data/Temperature/hourly_temp_NOAA.dta", clear 
	
	collapse rainfall temperature_c humidity, by(day month year)
	egen date = group(year month day)
	
	gen l1_temp = temperature_c[_n - 1]
	gen l2_temp = temperature_c[_n - 2]
	gen l3_temp = temperature_c[_n - 3]
	gen l4_temp = temperature_c[_n - 4]
	gen l5_temp = temperature_c[_n - 5]
	gen l6_temp = temperature_c[_n - 6]
	gen l7_temp = temperature_c[_n - 7]
	gen l8_temp = temperature_c[_n - 8]
	gen l9_temp = temperature_c[_n - 9]
	gen l10_temp = temperature_c[_n - 10]
	
	tempfile lags
	save `lags'
	
	restore 
	
	* merge lags 
	
	merge m:1 day month year using "`lags'"
	drop if _merge==2
	drop _merge
