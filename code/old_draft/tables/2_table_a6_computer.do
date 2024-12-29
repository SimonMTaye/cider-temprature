/****************************************************************
****************************************************************
File:		2_table_a6.do
Purpose:	Generate Table A6: Effects of Temperature on Absenteeism


Author:		Isadora Frankenthal

Modified By:	Simon Taye

Note:		Code uses variables that aren't part of the dataset anymore.
		I changed them based on which variables they most likely matched
		and context from the paper.
Changes: 
		l1_temp ->	l1_workday_temperature_c
			* Following the lagged temperature variable used for other tables
			* eg. Table 2
		* high_temp  / med_temp / lower_temp
			* generated temperature quartiles using code from Fig A2
			* original code in archive hard coded quartile values but
			* this goes against recommended practice

		
****************************************************************
****************************************************************/
* absenteeism, checkin / checkout time 
	
use "$data/generated/absenteeism_time_temp.dta", clear 

/* 
For replication purposes
use "$data/raw/hours_of_work.dta", clear 
		keep pid day_in_study day month year at_present_check checkin_time checkout_time hrs_of_work
 	preserve

	use "$data/generated/hi_hourly_temp_NOAA_indiatime.dta", clear 
	
		keep if time_india>900 & time_india<1900
		collapse (mean) workday_temperature_c=temperature_c, by (day year month)
		
		egen date = group(year month day)
		sort date
		gen l1_workday_temperature_c = workday_temperature_c[_n - 1]
			
		tempfile temp
		save `temp'
	
	restore 
	
	
	merge m:1 day month year using "`temp'"
	drop if _merge==2
	drop _merge 
	*/

	eststo clear
	xtset pid day_in_study
	
		
	xtile temp_q	= workday_temperature_c, nq(4)
	gen high			= temp_q == 4
	gen medium		= temp_q == 3
	gen low				= temp_q == 2

	
	label var l1_workday_temperature_c "Lag 1 of Temperature"
	label var high "High Temperature (=1)"
	label var medium "Medium Temperature (=1)"
	label var low "Low Temperature (=1)"
	
	
	// new absenteeism + checkin checkout for appendix / extra checks 
	
	reghdfe at_present_check workday_temperature_c l1_workday_temperature_c if computer == 0, absorb(pid day_in_study month#year) cluster(pid)
		summ at_present_check if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
		estadd local computer = "No"
	eststo

	reghdfe at_present_check workday_temperature_c l1_workday_temperature_c if computer == 1, absorb(pid day_in_study month#year) cluster(pid)
		summ at_present_check if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
		estadd local computer = "Yes"
	eststo

	reghdfe checkin_time workday_temperature_c l1_workday_temperature_c if hrs_of_work!=. & computer == 0, absorb(pid day_in_study month#year) cluster(pid)
		summ checkin_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
		estadd local computer = "No"
	eststo

	reghdfe checkin_time workday_temperature_c l1_workday_temperature_c if hrs_of_work!=. & computer == 1, absorb(pid day_in_study month#year) cluster(pid)
		summ checkin_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
		estadd local computer = "Yes"
	eststo

		
	reghdfe checkout_time workday_temperature_c l1_workday_temperature_c if hrs_of_work!=. & computer == 0, absorb(pid day_in_study month#year) cluster(pid)
		summ checkout_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
		estadd local computer = "No"
	eststo

	reghdfe checkout_time workday_temperature_c l1_workday_temperature_c if hrs_of_work!=. & computer == 1, absorb(pid day_in_study month#year) cluster(pid)
		summ checkout_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
		estadd local computer = "Yes"
	eststo

	table_header "Dependent Variable:" 6
	local header prehead(`r(header_macro)')
	model_titles "\textbf{Participant Present} (=1)" "\textbf{Check-in Time}" "\textbf{Check-out Time}" , pattern("1 0 1 0 1 0")
	local titles `r(model_title)'
	#delimit ;
	esttab * using "$output/tables/table_a6_computer.tex", replace ///
		scalars("computer Computer?" "mean Dependent Variable Mean"  "num_obs Observations" "r2 R-squared" ) ///
		$esttab_opts `header' `titles';
	#delimit cr;



	
