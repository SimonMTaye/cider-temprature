/****************************************************************
****************************************************************
File:		2_growth_two_day_temp_lead
Purpose:	//TODO: Fill in


Author:		Isadora Frankenthal
Modified By:	Simon Taye


Note: Original file you shared had the unlagged temprature when check for p-value == 0, is that what you want?
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_twoday.dta", clear
    local base_condition_1 two_days>2 & learning_half == 1
    local name_1 "$output/tables/table_growth_w_lead.tex"

    local base_condition_2 two_days>2 
    local name_2 "$output/tables/table_growth_w_lead_full_sample.tex"

    forvalues j=1/2 {
    
    local filename `name_`j''

    eststo clear

    drop if max_absents == 1

    // Define regression specifications here
    //  * dep_var -> dependent variable which is constant for all regs
    //  * se_spec -> clustering and FE which is constant

    //  * condition_`i' -> Sample condition for regression i
    //  * indep_var_`i' -> Explanatory variable for regression i
    //  * dep_var_lag_`i' -> Indicator for whether regression i controls for lagged depedent variable

    local dep_var growth_quality_output_two_days
    local se_spec absorb(pid two_days month#year) cluster(pid)

    local base_condition `base_condition_`j''
    local indep_vars temp_c_two_days ld1_temp_c_two_days ld2_temp_c_two_days ld3_temp_c_two_days 
    local indep_vars_lag `indep_vars' l.growth_quality_output_two_days
    

    local condition_1 `base_condition'
    local indep_var_1 `indep_vars'
    local dep_var_lag_1 "No"

    local condition_2 `base_condition'
    local indep_var_2 `indep_vars_lag' 
    local dep_var_lag_2 "Yes"

    local condition_3 `base_condition' & computer==0 
    local indep_var_3 `indep_vars_lag'
    local dep_var_lag_3 "Yes"

    local condition_4 `base_condition' & computer==1 
    local indep_var_4 `indep_vars_lag' 
    local dep_var_lag_4 "Yes"

    xtset pid two_days
    // Macros for storing custom row to display coefficient sum
    local sum_row "[1em] Sum of Lead Temperature Coefficents&"
    local pval_row ""

    forvalues i=1/4 {

        reghdfe `dep_var' `indep_var_`i'' if `condition_`i'', `se_spec' 
            summ `dep_var' if e(sample) == 1 
            estadd scalar mean = r(mean) 
            * Store number of observations
            estadd scalar num_obs = e(N)
            * Store 
            estadd local dep_var_lag = "`dep_var_lag_`i''"
            * Check
            local coeff_sum _b[ld1_temp_c_two_days] + _b[ld2_temp_c_two_days] + _b[ld3_temp_c_two_days] 
            estadd scalar c_sum = `coeff_sum'
            test `coeff_sum' = 0 
            estadd scalar p_value = r(p)
        eststo model_`i'
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

	table_header "Dependent Variable: \textbf{Productivity Growth}" 4
	local header prehead(`r(header_macro)')
    model_titles "Full Sample" "\shortstack{No Prior\\ Computer Experience}" "\shortstack{Computer Experience}", pattern("1 0 1 1") und
    local title `r(model_title)'

	#delimit ;
    esttab * using `filename', replace 
        `header' `title'
        scalars(
            "dep_var_lag Control for Lag of Dependent Variable" 
            "mean Dependent Variable Mean"
            "num_obs Observations" "r2 R-squared"
        ) 
        $esttab_opts keep(`indep_var_1');
        
	#delimit cr;

    insert_line `filename' 7 "`custom_row'"
    }
