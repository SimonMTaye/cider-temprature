/****************************************************************
****************************************************************
File:		2_growth_two_day_temp_lag
Purpose:	//TODO: Fill in


Author:		Isadora Frankenthal
Modified By:	Simon Taye


Note: Original file you shared had the unlagged temprature when check for p-value == 0, is that what you want?
****************************************************************
****************************************************************/
/// Panel A -> No lag
use "$data/generated/hi_analysis_twoday.dta", clear

        ereturn clear
        eststo clear

        local filename "$output/tables/table_growth_placebo.tex"

        drop if max_absents == 1
        xtset pid two_days

        local dep_var growth_quality_output_two_days
        local se_spec absorb(pid two_days month#year) cluster(pid)

        local indep_vars temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days 
        local indep_vars_lag `indep_vars' l.growth_quality_output_two_days
        local base_condition two_days>2

        // First half with no lag
        local condition_1 `base_condition' & learning_half == 1
        local indep_var_1   `indep_vars'
        local dep_var_lag_1 "No"

        // Second half with no lag
        local condition_2 `base_condition' & learning_half == 0
        local indep_var_2   `indep_vars'
        local dep_var_lag_2 "No"

        // First half with lag
        local condition_3 `base_condition' & learning_half == 1
        local indep_var_3   `indep_vars_lag'
        local dep_var_lag_3 "Yes"

        // Second half with lag
        local condition_4 `base_condition' & learning_half == 0
        local indep_var_4  `indep_vars_lag'
        local dep_var_lag_4 "Yes"

        // Macros for storing custom row to display coefficient sum
        local sum_row "[1em] Sum of Temperature Coefficents&"
        local pval_row ""

        forvalues i=1/4 {
            reghdfe `dep_var' `indep_var_`i'' if `condition_`i'', `se_spec' 
                summ `dep_var' if e(sample) == 1 
                estadd scalar mean = r(mean) 
                * store number of observations
                estadd scalar num_obs = e(N)
                * store lagged exists indicator
                estadd local dep_var_lag = "`dep_var_lag_`i''"
                * Store sum of temp coeffcients and p-value 
            eststo model_`i'
                local coeff_sum _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
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

        local custom_row "`sum_row' \\ `pval_row' \\"

        * Output table
        table_header  "Dependent Variable: \textbf{Productivity Growth}" 4
        local header prehead(`r(header_macro)')

        model_titles "\shortstack{First Half\\ of Study}" "\shortstack{Second Half\\ of Study}" "\shortstack{First Half\\ of Study}" "\shortstack{Second Half\\ of Study}", und
        local title `r(model_title)'
        // Cutting r2 from the table since it not consistent within the two panels
        #delimit ;
        esttab * using `filename', replace 
            nomtitle num `header' `title' noisily
            scalars(
                "dep_var_lag Control for Lag of Dependent Variable" 
                "mean Dependent Variable Mean"
                "num_obs Observations" 
            ) 
            $esttab_opts keep(`indep_var_1');
        #delimit cr;



        insert_line `filename' 7 "`custom_row'"

    //nl (m_quality_output  = {b0} + {b1}*two_days + {b2}*max(0, day_in_study - {b3})), initial(b3 25) iterate(1000000)