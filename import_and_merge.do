
	//global dir "/Users/isadorafrankenthal/Dropbox/Temperature" 
	//global root "/Users/st2246/Dropbox/Temperature" 
	global data "$root/data"
	
	import delimited "$data/Temperature/updated_hourly_temp_NOAA.csv", clear

		drop if forecasttime==0 
		
		drop day month year
		
		tostring datadate, replace
		gen month = substr(datadate, -4, 2)
		gen day = substr(datadate, -2, 2)
		gen year = substr(datadate, -8, 4)
		
		destring time, replace 
		destring day, replace
		destring month, replace
		destring year, replace 
		
		replace time = 0 if time==2400
		
		* convert kelvin to celsius 
		
	// 	gen temperature_c = temperature_k - 273.15
		
	save "$data/generated/Temperature/hi_hourly_temp_NOAA.dta", replace 
	
	
	* convert into india time 
	
	use "$data/generated/hi_hourly_temp_NOAA.dta", clear 
	
	drop *_india
	
	gen time_india = time + 500
	gen day_india = day 
	gen month_india = month 
	gen year_india = year
	
		* day adjustment 
	
	replace day_india = day_india + 1 if inrange(time_india, 2400, 2800)
	replace time_india = 0 if time_india==2400
	replace time_india = 100 if time_india==2500
	replace time_india = 200 if time_india==2600
	replace time_india = 300 if time_india==2700
	replace time_india = 400 if time_india==2800
	
		* year adjustment 
		
	replace year = year + 1 if day_india>31 & month==12 
		

		* month adjustment
	
	replace month_india = month + 1 if day_india>31
	replace day_india = 1 if day_india>31
	replace month_india = 1 if month_india==13
	
	replace month_india = month_india + 1 if day_india==31 & (month==9 | month==4 | month==6 | month==11)
	replace day_india = 1 if day_india==31 & (month==9 | month==4 | month==6 | month==11)
	
	
	replace month_india = month_india + 1 if day_india>28 & month==2
	replace day_india = 1 if day_india>28 & month==2
	
	keep if inrange(year, 2017, 2019)
 
	drop day month year 
	rename day_india day 
	rename month_india month
	rename year_india year 
	
	drop _merge
	
	save "$data/generated/hi_hourly_temp_NOAA_indiatime.dta", replace
	


	* merge temperature and productivity 
	
	use "$data/hourly_productivity.dta", clear 
	
	keep if dropout_category!=2
	egen date = group(year month day)
	
	replace typing_time=5 if typing_time>5
	
	* get rid of lunch time, nap time, survey time... 
	
	* lunch time 
	
	gen clock_ = clock 
	drop if clock_>=45000000 & clock<=46800000
	
	* nap time 
	
	preserve 
	use "$data/analysis_base.dta", clear
	keep pid day_in_study post_lunch_activity
	tempfile nap 
	save `nap'
	restore
	
	merge m:1 pid day_in_study using "`nap'"
	drop if _merge==2
	drop _merge 

	// TODO check
	drop if clock_>=48600000 & clock<=50100000 & post_lunch_activity!=3 & day_in_study>9 & day_in_study!=28
	drop if clock_>=51900000 & clock<=57600000 & typing_time==0
	
	
	drop clock_ 
	
	keep if time>=900 
	keep if time<=2000
	
	
	collapse (mean) salience fraction_high (firstnm) date day month year day_type (sum) performance_earnings attendance_earnings typing_time correct_entries voluntary_pause mistakes_number, by(pid day_in_study time)
	
	rename time time_india
	

	merge m:1 day month year time_india using "$data/generated/hi_hourly_temp_NOAA_indiatime.dta"
	keep if _merge==3 
	drop _merge 
	
	
	* constructing variables
	
	gen total_entries = correct_entries + mistakes_number

	gen productivity = correct_entries/typing_time
	replace productivity=productivity*60

	gen mistakes_per_entries = mistakes_number/total_entries
	
	gen mistakes_per_entries_00 = mistakes_per_entries*100
	gen quality_output = correct_entries - 8*mistakes_number 
	
	egen pid_day = group(pid day_in_study)
	xtset pid_day time
	
	
	* merge checkin checkout time 
	
	merge m:1 pid day_in_study using "$data/checkin_checkout.dta"
	drop if _merge==2 
	drop _merge
	
	gen round_checkin = round(checkin_time)
	gen round_checkout = round(checkout_time)
	
	tostring round_checkin, replace 
	tostring round_checkout, replace 
	
	replace round_checkin = round_checkin +"00"
	replace round_checkout = round_checkout +"00"
	
	destring round_checkin, replace 
	destring round_checkout, replace 
	
	keep if time_india >= round_checkin & time_india <= round_checkout
	
	* winsorize
	foreach var in mistakes_number total_entries correct_entries quality_output typing_time {
		rename `var' `var'_uw
		winsor `var'_uw, p(0.05) highonly generate(`var'_w)
		rename `var'_w `var'
	}
	
	
	save "$data/generated/hi_analysis_hourly.dta", replace 
	
	
	* creating daily dataset 
	
	gen m_quality_output = quality_output
	gen m_correct_entries = correct_entries
	gen m_typing_time = typing_time
	gen m_total_entries = total_entries
	gen m_mistakes_number = mistakes_number
	
	
	gen one = 1 
	egen count_hours = sum(one), by (pid day_in_study)

	
	collapse (mean) m_mistakes_number heat_index m_total_entries m_correct_entries m_quality_output m_typing_time temperature_c fraction_high count_hours (firstnm) date day month year day_type (sum) quality_output performance_earnings attendance_earnings typing_time correct_entries voluntary_pause mistakes_number total_entries mistakes_per_entries_00, by(pid day_in_study)
	
	
	* merge temperature lags 
	
	preserve 
	use "$data/generated/hi_hourly_temp_NOAA_indiatime.dta", clear 
	
	
	// TODO unclear what is going on here
	egen temp_1 = mean(temperature_c) if time_india >= 600 & time_india<=2300, by (day month year)
	egen temp_2 = mean(temperature_c) if time_india >= 700 & time_india<=2300, by (day month year)
	egen temp_3 = mean(temperature_c) if time_india >= 800 & time_india<=2300, by (day month year)
	egen temp_4 = mean(temperature_c) if time_india >= 900 & time_india<=2300, by (day month year)
	egen temp_5 = mean(temperature_c) if time_india >= 1000 & time_india<=2300, by (day month year)
	egen temp_6= mean(temperature_c) if time_india >= 600 & time_india<=2200, by (day month year)
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
	
	restore 
	
	* merge lags 
	
	merge m:1 day month year using "`lags'"
	drop if _merge==2
	drop _merge
	
	merge m:1 pid using "$data/raw/baseline_cleaned.dta"
	drop _merge 
	
	gen english = a15
	gen computer = a23
	
// 	save "/Users/isadorafrankenthal/Dropbox/Temperature/Data/2. Main Study/01. Raw Data/Productivity/for_learning.dta", replace 
	
	
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
	
	save "$data/generated/hi_analysis_daily.dta", replace
	
	preserve 
	
	
 * add daily pollution data 
 
	import excel "$data/raw/pollution_added.xls", sheet("Sheet1") firstrow clear

	collapse PM25, by(day month year)
 
	tempfile pollution
	save `pollution'
 
	restore 
	
	merge m:1 day month year using "`pollution'"
	drop if _merge==2 
	drop _merge 
	
	
 
	
// 	foreach var in m_mistakes_number m_total_entries m_correct_entries m_quality_output m_typing_time {
// 	rename `var' `var'_uw
// 	winsor `var'_uw, p(0.05) highonly generate(`var'_w)
// 	rename `var'_w `var'
// 	}
//	
	save "$data/generated/hi_analysis_daily.dta", replace
 
 
 
 
 
 
 
 
 
 
 
	
	
	
	
