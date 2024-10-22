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
		l1_temp ->	l1_temperature_c
			* Following the lagged temperature variable used for other tables
			* eg. Table 2
		* high_temp  / med_temp / lower_temp
			* generated temperature quartiles using code from Fig A2
			* original code in archive hard coded quartile values but
			* this goes against recommended practice

		
****************************************************************
****************************************************************/
* absenteeism, checkin / checkout time 
	
use "$data/generated/hi_analysis_daily.dta", clear 


	eststo clear
	
	/*
	// Code from archive/absenteeism.do
	// Adapated using quartile code from Figure A2 to avoid harcoded values
	gen high = 0 
	replace high=1 if inrange(tempc, 30.01, 35)
	gen medium = 0 
	replace medium=1 if inrange(tempc, 28.01, 30) 
	gen low = 0 
	replace low = 1 if inrange(tempc, 26.01, 28)
			
	gen high_temp = high*tempc
	gen medium_temp = medium*tempc 
	gen low_temp = low*tempc
	*/
		
	xtile temp_q	= temperature_c, nq(4)
	gen high	= temp_q == 4
	gen medium	= temp_q == 3
	gen low		= temp_q == 2
	gen high_temp	= high*temperature_c
	gen medium_temp = medium*temperature_c
	gen lower_temp	= low*temperature_c

	
	label var l1_temperature_c "Lag 1 of Temperature"
	label var high_temp "High Temperature (=1)"
	label var medium_temp "Medium Temperature (=1)"
	label var lower_temp "Low Temperature (=1)"
	
	
	// new absenteeism + checkin checkout for appendix / extra checks 
	
	reghdfe at_present_check temperature_c l1_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ at_present_check if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	reghdfe at_present_check high_temp medium_temp lower_temp, absorb(pid day_in_study month#year) cluster(pid)
		summ at_present_check if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	
	reghdfe checkin_time temperature_c l1_temperature_c if hrs_of_work!=., absorb(pid day_in_study month#year) cluster(pid)
		summ checkin_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	reghdfe checkin_time high_temp medium_temp lower_temp if hrs_of_work!=., absorb(pid day_in_study month#year) cluster(pid)
		summ checkin_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	
	reghdfe checkout_time temperature_c l1_temperature_c if hrs_of_work!=., absorb(pid day_in_study month#year) cluster(pid)
		summ checkout_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	reghdfe checkout_time high_temp medium_temp lower_temp if hrs_of_work!=., absorb(pid day_in_study month#year) cluster(pid)
		summ checkout_time if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	
	reghdfe hrs_of_work temperature_c l1_temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		summ hrs_of_work if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	reghdfe hrs_of_work high_temp medium_temp lower_temp, absorb(pid day_in_study month#year) cluster(pid)
		summ hrs_of_work if e(sample) == 1 
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo


	table_header "Dependent Variable:" 8
	local header prehead(`r(header_macro)')
	model_titles "\textbf{Participant Present} (=1)" "\textbf{Check-in Time}" "\textbf{Check-out Time}" "\textbf{Total Hours of Work}", pattern("1 0 1 0 1 0 1 0")
	local titles `r(model_title)'
	#delimit ;
	esttab * using "$output/tables/table_a6.tex", replace ///
		scalars("mean Dependent Variable Mean"  "num_obs Observations" "r2 R-squared" ) ///
		$esttab_opts `header' `titles';
	#delimit cr;



	
