/****************************************************************
****************************************************************
File:		1_2_join_temp_prod
Purpose:	Joins temprature and productivity data as well as collapeses to the day level

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/raw/hourly_productivity.dta", clear 
	
	* drop obs who dropped out at baseline
	keep if dropout_category !=2
	egen date = group(year month day)
	
	replace typing_time=5 if typing_time>5
	
****Get rid of lunch time, nap time, survey time... 
	
	* lunch time 
	gen clock_ = clock 
	drop if clock_>=45000000 & clock<=46800000
	
	* nap time 
	preserve 

		use "$data/raw/analysis_base.dta", clear
		keep pid day_in_study post_lunch_activity
		tempfile nap 
		save `nap'

	restore
	
	merge m:1 pid day_in_study using "`nap'"
	drop if _merge==2
	drop _merge 

	// TODO: Annotate
	drop if clock_>=48600000 & clock<=50100000 & post_lunch_activity!=3 & day_in_study>9 & day_in_study!=28
	drop if clock_>=51900000 & clock<=57600000 & typing_time==0
	drop clock_ 
	keep if time>=900 
	keep if time<=2000
	
	collapse (mean) salience fraction_high (firstnm) date day month year day_type (sum) performance_earnings attendance_earnings typing_time correct_entries voluntary_pause mistakes_number, by(pid day_in_study time)
	
	rename time time_india




******** Merge other data
	* temprature data
	merge m:1 day month year time_india using "$data/generated/hi_hourly_temp_NOAA_indiatime.dta"
	keep if _merge==3 
	drop _merge 

******** Construct Productivity variables 
	gen total_entries = correct_entries + mistakes_number
	gen productivity = correct_entries/typing_time
	replace productivity=productivity*60
	gen mistakes_per_entries = mistakes_number/total_entries
	gen mistakes_per_entries_00 = mistakes_per_entries*100
	gen quality_output = correct_entries - 8*mistakes_number 
	
******** Define panel variables
	egen pid_day = group(pid day_in_study)
	xtset pid_day time
	
	
	* checkin / checkout data
	merge m:1 pid day_in_study using "$data/raw/checkin_checkout.dta"
	drop if _merge==2 
	drop _merge
	
	// TODO: How to handle missing values?
	gen round_checkin = round(checkin_time)
	gen round_checkout = round(checkout_time)

	replace round_checkin = round_checkin * 100
	replace round_checkout = round_checkout * 100
	
	replace round_checkin = 0 if round_checkin == .
	replace round_checkout = 0 if round_checkout == .

	
	/*
	tostring round_checkin, replace 
	tostring round_checkout, replace 
	
	replace round_checkin = round_checkin +"00"
	replace round_checkout = round_checkout +"00"
	
	destring round_checkin, replace 
	destring round_checkout, replace 
	*/

	keep if time_india >= round_checkin & time_india <= round_checkout
	
	* winsorize
	foreach var in mistakes_number total_entries correct_entries quality_output typing_time {
		rename `var' `var'_uw
		winsor `var'_uw, p(0.05) highonly generate(`var'_w)
		rename `var'_w `var'
	}
	
	label var temperature_c "Temprature (Celsius)"

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
	
	label var temperature_c "Temprature (Celsius)"

save "$data/generated/hi_analysis_daily.dta", replace 
	
