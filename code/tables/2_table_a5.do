/****************************************************************
****************************************************************
File:		2_table_a5.do
Purpose:	Generate Table A5: Effect of Temperature on Abseentism


Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear 

	eststo clear
	reghdfe at_present_check temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		sum at_present_check if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe checkin_time temperature_c if hrs_of_work!=., absorb(pid day_in_study month#year) cluster(pid)
		sum checkin_time if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo
	
	reghdfe checkout_time temperature_c if hrs_of_work!=., absorb(pid day_in_study month#year) cluster(pid)
		sum checkout_time if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	
	reghdfe hrs_of_work temperature_c, absorb(pid day_in_study month#year) cluster(pid)
		sum hrs_of_work if e(sample)==1
		estadd scalar num_obs = e(N)
		estadd scalar mean = r(mean) 
		estadd scalar sd = r(sd)
	eststo

	table_header "Dependent Variable is" 4
	#delimit ;
	esttab * using "$output/tables/table_a5.tex",  replace 
		$esttab_opts
		prehead(`r(header_macro)')
		scalars("mean Dependent Variable Mean"  "num_obs Observations" "r2 R-squared")
		mlabels("\shortstack{\textbf{Participant Present}\\(=1)}" 
				"\textbf{Check-in Time}" 
				"\textbf{Check-out Time}" 
				"\shortstack{\textbf{Total Hours of}\\ \textbf{Work}}" 
			prefix(\multicolumn{@span}{c}{) suffix(}) 
			span erepeat(\cmidrule(lr){@span}))  ;
	#delimit cr;

