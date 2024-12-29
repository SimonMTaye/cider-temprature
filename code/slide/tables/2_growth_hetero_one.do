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
use "$data/generated/hi_analysis_daily.dta", clear
    drop if max_absents == 1
    xtset pid day_in_study


    local base_condition (day_in_study>1) & (learning_half == 1)
    local filename "$output/tables/table_growth_hetero_one_slide.tex"

    ereturn clear
    eststo clear

    local dep_var growth_quality_output
    local se_spec absorb(pid two_days month#year) cluster(pid)

    local temp_var temperature_c
    local indep_vars `temp_var' l1_`temp_var' l2_`temp_var' l3_`temp_var' 

    local indep_vars_lag `indep_vars' l_growth_quality_output

    // First half with lag
    local condition_1 `base_condition'
    local indep_var_1   `indep_vars_lag'
    local dep_var_lag_1 "Yes"

    // No Prior Computer Experience with lag
    local condition_2 (`base_condition') & computer==0 
    local indep_var_2   `indep_vars_lag'
    local dep_var_lag_2 "Yes"

    // Prior Computer Experience with lag
    local condition_3 `base_condition' & computer==1 
    local indep_var_3   `indep_vars_lag'
    local dep_var_lag_3 "Yes"

    // No English
    local condition_4 (`base_condition') & english ==0 
    local indep_var_4   `indep_vars_lag'
    local dep_var_lag_4 "Yes"

    // English
    local condition_5 `base_condition' & english ==1 
    local indep_var_5   `indep_vars_lag'
    local dep_var_lag_5 "Yes"



    // Macros for storing custom row to display coefficient sum
    local sum_row " Sum of Temperature Coefficents&"
    local pval_row ""

    forvalues i=2/5 {
        reghdfe `dep_var' `indep_var_`i'' if `condition_`i'', `se_spec' 
            summ `dep_var' if e(sample) == 1 
            estadd scalar mean = r(mean) 
            estadd scalar sd_g = r(sd) 
            * store number of observations
            estadd scalar num_obs = e(N)
            * store lagged exists indicator
            estadd local dep_var_lag = "`dep_var_lag_`i''"
            // Add variation of temperature
            sum `temp_var' if e(sample)
            estadd scalar sd_temp = r(sd)
            * Store sum of temp coeffcients and p-value 
        eststo model_`i'
            local coeff_sum
            foreach var in `indep_vars' {
                local coeff_sum `coeff_sum' _b[`var'] + 
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

    local custom_row "`sum_row' \\ `pval_row' \\ [1em]"

    * Output table
    table_header  "Dependent Variable: \textbf{Productivity Growth}" 4
    local header prehead(`r(header_macro)')

    // 
    model_titles  "\shortstack{No Prior\\ Computer Experience}" "\shortstack{Computer Experience}" "No English" "English Speaker" , und
    local title `r(model_title)'
    // Cutting r2 from the table since it not consistent within the two panels
    #delimit ;
    esttab * using `filename', replace 
        nomtitle num `header' `title' 
        scalars(
            "dep_var_lag Control for Lag of Dependent Variable" 
            "mean Dependent Variable Mean"
            "sd_g Dependent Variable SD"
            "num_obs Observations" 
            "r2 R-squared"
        ) 
        $esttab_opts keep(`temp_var');
    #delimit cr;

    // Insert manually constructed Sum of coefficent row at line 7 of the table
    insert_line `filename' 5 "`custom_row'"
