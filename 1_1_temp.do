/****************************************************************
****************************************************************
File:		11_temp
Purpose:	Imports Hourly Temprature data from NOAA and converts
		time to local indian time

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
import delimited "$data/raw/updated_hourly_temp_NOAA.csv", clear

***** Set day month year variables to be based on datadate
	* drop errant merge variable so it doesn't cause issues later
	drop _merge

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
	
	pause

	replace time = 0 if time==2400
		
***** Convert into india time 
	
	drop *_india

	gen time_india = time + 500
	gen day_india = day 
	gen month_india = month 
	gen year_india = year
	
	* timezone adjustments

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
	
	
	
save "$data/generated/hi_hourly_temp_NOAA_indiatime.dta", replace
	
