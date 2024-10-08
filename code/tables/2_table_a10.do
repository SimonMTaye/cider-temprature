/****************************************************************
****************************************************************
File:		2_table_a10.do
Purpose:	Generate Table A10: Temperature Effect on Productivity Growth

Author:		Isadora Frankenthal

Modified By:	Simon Taye
****************************************************************
****************************************************************/
//INFO: Switched from outreg2 to esttab to get formatting to work correctly

clear all
* learning with growth rates
use "$data/generated/hi_analysis_twoday.dta", clear 


    xtset pid two_days

    label var temp_c_two_days_workday "Temperature (Celcius)"
    
    * contemporaneous 
    
    reghdfe growth_quality_output_two_days temp_c_two_days_workday, absorb(pid two_days month#year) cluster(pid)
        estadd scalar num_obs = e(N)
        estadd scalar coeff_sum = .
        estadd scalar p_value = .
    eststo
    
    
    reghdfe growth_quality_output_two_days temp_c_two_days_workday if two_days<9, absorb(pid two_days month#year) cluster(pid)
        estadd scalar num_obs = e(N)
        estadd scalar coeff_sum = .
        estadd scalar p_value = .
    eststo
        
    reghdfe growth_quality_output_two_days temp_c_two_days_workday if computer==0, absorb(pid two_days month#year) cluster(pid)
        estadd scalar num_obs e(N)
        estadd scalar coeff_sum = .
        estadd scalar p_value = .
    eststo
    
    

    * three lags 
    
    
    
    reghdfe growth_quality_output_two_days temp_c_two_days_workday l1_temp_c_two_days_workday l2_temp_c_two_days_workday l3_temp_c_two_days_workday if two_days>=4, absorb(pid two_days month#year) cluster(pid)
        * Store number of observations
        estadd scalar num_obs = e(N)
        * Calculate the sum of the coefficients
        estadd scalar coeff_sum = _b[temp_c_two_days_workday] + _b[l1_temp_c_two_days_workday] + _b[l2_temp_c_two_days_workday] + _b[l3_temp_c_two_days_workday]
        * Perform the test and store the p-value
        test _b[temp_c_two_days_workday] + _b[l1_temp_c_two_days_workday] + _b[l2_temp_c_two_days_workday] + _b[l3_temp_c_two_days_workday] = 0
        estadd scalar p_value = r(p)
    eststo
        

    reghdfe growth_quality_output_two_days temp_c_two_days_workday l1_temp_c_two_days_workday l2_temp_c_two_days_workday l3_temp_c_two_days_workday if two_days>=4 & two_days<9, absorb(pid two_days month#year) cluster(pid)
        * Store number of observations
        estadd scalar num_obs = e(N)
        * Calculate the sum of the coefficients
        estadd scalar coeff_sum = _b[temp_c_two_days_workday] + _b[l1_temp_c_two_days_workday] + _b[l2_temp_c_two_days_workday] + _b[l3_temp_c_two_days_workday]
        * Perform the test and store the p-value
        test _b[temp_c_two_days_workday] + _b[l1_temp_c_two_days_workday] + _b[l2_temp_c_two_days_workday] + _b[l3_temp_c_two_days_workday] = 0
        estadd scalar p_value = r(p)
    eststo
        
    reghdfe growth_quality_output_two_days temp_c_two_days_workday l1_temp_c_two_days_workday l2_temp_c_two_days_workday l3_temp_c_two_days_workday if two_days>=4 & computer==0, absorb(pid two_days month#year) cluster(pid)
        * Store number of observations
        estadd scalar num_obs = e(N)
        * Calculate the sum of the coefficients
        estadd scalar coeff_sum = _b[temp_c_two_days_workday] + _b[l1_temp_c_two_days_workday] + _b[l2_temp_c_two_days_workday] + _b[l3_temp_c_two_days_workday]
        * Perform the test and store the p-value
        test _b[temp_c_two_days_workday] + _b[l1_temp_c_two_days_workday] + _b[l2_temp_c_two_days_workday] + _b[l3_temp_c_two_days_workday] = 0
        estadd scalar p_value = r(p)
    eststo

    #delimit ;
    esttab * using "$output/tables/table_a10.tex",  replace
        $esttab_opts keep(temp_c_two_days_workday) 
        scalars("coeff_sum Sum of Lagged Temperature Coefficients, Lead 1 to N" "p_value p-value" "r2 R-squared" "num_obs Observations") 
        mtitles("\shortstack{Full Study\\ period}" "\shortstack{First half of\\study}" "\shortstack{No Prior\\Computer\\Experience}" "\shortstack{Full study\\ period}" "\shortstack{First half of\\ study}" "\shortstack{No Prior\\Computer\\Experience}") ///
        mgroups("Dependent Variable is \textbf{Growth in Average Hourly Quality Adjusted Output}",
            pattern(1 0 0 0 0 0) 
            prefix(\multicolumn{@span}{c}{) suffix(}) 
            span erepeat(\cmidrule(lr){@span})) ; 
    #delimit cr 


    
    
    
    
