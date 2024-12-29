/****************************************************************
****************************************************************
File:		2_growth_robustness
Purpose:	//TODO: Fill in


Authoer :	Simon Taye


Note: Original file you shared had the unlagged temprature when check for p-value == 0, is that what you want?
****************************************************************
****************************************************************/
/// Panel A -> No lag
use "$data/generated/hi_analysis_twoday.dta", clear
    drop if max_absents == 1
    xtset pid two_days


    local filename "$output/tables/table_growth_robustness.tex"


    local first_column "\shortstack{First Half\\ of Study}"

    ereturn clear
    eststo clear

    local dep_var growth_quality_output_two_days
    local se_spec absorb(pid two_days month#year) cluster(pid)

    local temp_var temp_c_two_days
    local base_condition (two_days>2) & (learning_half == 1)

    // First half with no lag
    local condition_1 `base_condition'
    local indep_var_1   `temp_var'
    local dep_var_lag_1 "No"

    // First half with lag
    local condition_2 `base_condition'
    local indep_var_2   `temp_var' l_growth_quality_output_two_days
    local dep_var_lag_2 "Yes"

    // First half with one lag
    local condition_3 `base_condition'
    local indep_var_3   `temp_var' l1_`temp_var'  
    local dep_var_lag_3 "No"

    // First half with one lag and lag dep
    local condition_4 `base_condition'
    local indep_var_4   `indep_var_3' l_growth_quality_output_two_days
    local dep_var_lag_4 "Yes"

    // First half with three lag
    local condition_5 `base_condition'
    local indep_var_5   `temp_var' l1_`temp_var' l2_`temp_var' 
    local dep_var_lag_5 "No"

    // First half with three lag and lag dep
    local condition_6 `base_condition'
    local indep_var_6   `indep_var_5' l_growth_quality_output_two_days
    local dep_var_lag_6 "Yes"

    // First half with three lag
    local condition_7 `base_condition'
    local indep_var_7   `temp_var' l1_`temp_var' l2_`temp_var' l3_`temp_var'
    local dep_var_lag_7 "No"

    // First half with three lag and lag dep
    local condition_8 `base_condition'
    local indep_var_8   `indep_var_7' l_growth_quality_output_two_days
    local dep_var_lag_8 "Yes"


    /* 4 lag
    local condition_7 `base_condition'
    local indep_var_7   `temp_var' l1_`temp_var' l2_`temp_var' l3_`temp_var' l4_`temp_var'
    local dep_var_lag_7 "No"

    
    local condition_8 `base_condition'
    local indep_var_8   `indep_var_7' l_growth_quality_output_two_days
    local dep_var_lag_8 "Yes"
    */

    /* 3 lag + hrs_of_work_control
    local condition_7 `base_condition'
    local indep_var_7   `indep_var_6' hrs_of_work 
    local dep_var_lag_7 "Yes"
    */

    // Macros for storing custom row to display coefficient sum
    local sum_row " \\ [-1.7ex] Sum of Temperature Coefficents& "
    local pval_row ""

    forvalues i=1/8 {
        reghdfe `dep_var' `indep_var_`i'' if `condition_`i'', `se_spec' 
            summ `dep_var' if e(sample) == 1 
            estadd scalar mean = r(mean) 
            * store number of observations
            estadd scalar num_obs = e(N)
            * store lagged exists indicator
            estadd local dep_var_lag = "`dep_var_lag_`i''"
            * Store sum of temp coeffcients and p-value 
        eststo model_`i'
            local coeff_sum
            foreach var in `indep_var_`i'' {
                if "`var'" != "l_growth_quality_output_two_days" { // & "`var'" != "`temp_var'" {
                    local coeff_sum `coeff_sum' _b[`var'] + 
                }
            }
            local coeff_sum `coeff_sum' 0
            test  `coeff_sum' = 0 
            local p_value_`i' = r(p) 
            local c_sum_`i' = `coeff_sum'
            // Construct custom row for displaying coeff_sum and p-value
            // Add stars to coefficent
            add_stars `c_sum_`i'' `p_value_`i''
            local c_sum_star_`i' `r(coeff_with_star)'
            local p_value_`i' = string(`p_value_`i'', "%5.3f")
            // Append coefficent sum row
            local sum_row "`sum_row' `c_sum_star_`i'' &"
            // Append to p-value row
            local pval_row "`pval_row' & [`p_value_`i'']"
    }

    local custom_row "`sum_row' \\ `pval_row' \\ \hline \\ [-1.7ex]"

    * Output table
    table_header  "Dependent Variable: \textbf{Productivity Growth}" 8
    local header prehead(`r(header_macro)')

        // Cutting r2 from the table since it not consistent within the two panels
        #delimit ;
        esttab * using `filename', replace 
            nomtitle num `header' `title'  nocons
            scalars(
                "dep_var_lag Control for Lag of Dependent Variable" 
                "mean Dependent Variable Mean"
                "num_obs Observations" 
                "r2 R-squared"
            ) 
            $esttab_opts drop(l_growth_quality_output_two_days _cons);
        #delimit cr;

        // Insert manually constructed Sum of coefficent row at line 7 of the table
        insert_line `filename' 4 "`custom_row'"