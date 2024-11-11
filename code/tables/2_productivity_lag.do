/****************************************************************
****************************************************************
File:		2_productivity_lag
Purpose:	//TODO: Fill in


Author:		Isadora Frankenthal
Modified By:	Simon Taye
****************************************************************
****************************************************************/

use "$data/generated/hi_analysis_daily.dta", clear

    drop if max_absents == 1

    xtset pid day_in_study

    // Define regression specifications here
    //  * dep_var -> dependent variable which is constant for all regs
    //  * se_spec -> clustering and FE which is constant

    //  * indep_var_`i' -> Explanatory variable for regression i
    //  * dep_var_lag_`i' -> Indicator for whether regression i controls for lagged depedent variable
    //  * test_`i' -> Test for sum of lag coefficents = 0. Leave empty to just include a . instead in reg table


    local dep_var m_quality_output
    local se_spec absorb(pid day_in_study month#year) cluster(pid)


    local temp_var temperature_c
    local indep_var_1 `temp_var'
    local p_test_1    ""
    local dep_var_lag_1 "No"

    local indep_var_3 `temp_var' l1_temperature_c
    local p_test_3    "_b[l1_temperature_c]"
    local dep_var_lag_3 "No"

    local indep_var_5 `temp_var' l1_temperature_c l2_temperature_c
    local p_test_5    "_b[l1_temperature_c] + _b[l2_temperature_c]"
    local dep_var_lag_5 "No"

    local indep_var_7 `temp_var' l1_temperature_c l2_temperature_c l3_temperature_c
    local p_test_7    "_b[l1_temperature_c] + _b[l2_temperature_c] + _b[l3_temperature_c]"
    local dep_var_lag_7 "No"

    // Generate dependent variable lags back filling to two-days ago if yesterday is missing
    gen l_`dep_var' = l.`dep_var'
    replace l_`dep_var' = l2.`dep_var' if missing(l_`dep_var')

    * Second half of the table is simply the first half + Control for lagged dep_var
    forvalues i=1/4 {
        * Get the corresponding column from the first half of the table
        local j = `i' * 2
        local k = `j' - 1
        
        local indep_var_`j' `indep_var_`k'' l_`dep_var'
        local p_test_`j' `p_test_`k''
        local dep_var_lag_`j' "Yes"
    }

    * Run regressions based on specifications above
    forvalues i=1/8 {
        reghdfe `dep_var' `indep_var_`i'', `se_spec'
            summ `dep_var' if e(sample) == 1 
            estadd scalar mean = r(mean) 
            * Store number of observations
            estadd scalar num_obs = e(N)
            estadd local dep_var_lag = "`dep_var_lag_`i''"

            * Run lagged coefs == 0 test if specified
            if "`p_test_`i''" != "" {
                * Remove extraneuos + at the beginning
                test `p_test_`i'' = 0
                estadd scalar p_value = r(p)
            }
            else {
                * If no lagged variables exist, set p_value to missing
                estadd scalar p_value = .
            }
        eststo model_`i'
    }

    table_header "Dependent Variable: \textbf{Productivity}" 8
	local header prehead(`r(header_macro)')
    model_titles "N = 0 Lags" "N = 1 Lag" "N = 2 Lags" "N = 3 Lags", pattern(1 0 1 0 1 0 1 0) und
    local title `r(model_title)'

    #delimit ;
    esttab * using "$output/tables/table_productivity.tex", replace 
        `header' `title'
        scalars( 
            "dep_var_lag Control for Lag of Dependent Variable" 
            "mean Dependent Variable Mean"
            "num_obs Observations" 
            "r2 R-squared") 
        $esttab_opts keep(`indep_var_7');
    #delimit cr;

