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

    local indep_var_1 temperature_c
    local p_test_1    ""
    local dep_var_lag_1 "No"

    local indep_var_2 temperature_c l1_temperature_c
    local p_test_2    "_b[l1_temperature_c]"
    local dep_var_lag_2 "No"

    local indep_var_3 temperature_c l1_temperature_c l2_temperature_c
    local p_test_3    "_b[l1_temperature_c] + _b[l2_temperature_c]"
    local dep_var_lag_3 "No"

    local indep_var_4 temperature_c l1_temperature_c l2_temperature_c l3_temperature_c
    local p_test_4    "_b[l1_temperature_c] + _b[l2_temperature_c] + _b[l3_temperature_c]"
    local dep_var_lag_4 "No"

    * Second half of the table is simply the first half + Control for lagged dep_var
    forvalues i=5/8 {
        * Get the corresponding column from the first half of the table
        local j = `i' - 4

        local indep_var_`i' `indep_var_`j'' l.`dep_var'
        local p_test_`i' `p_test_`j''
        local dep_var_lag_`i' "Yes"
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

    #delimit ;
    esttab * using "$output/tables/table_productivity.tex", replace 
        scalars("p_value p-value Sum of Lagged Temperature = 0" 
                "dep_var_lag Control for Lag of Dep. Var"  
                "mean Dep. Var. Mean"
                "num_obs Observations" 
                "r2 R-squared") 
        mtitles("N = 0" 
                "N = 1" 
                "N = 2" 
                "N = 3"
                "N = 0"
                "N = 1"
                "N = 2"
                "N = 3"
                ) 
        $esttab_opts keep(`indep_var_1') ;
    #delimit cr;

