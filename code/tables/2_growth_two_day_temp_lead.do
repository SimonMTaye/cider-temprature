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

    local temp_var temp_c_two_days
    local indep_vars `temp_var' ld1_`temp_var' ld2_`temp_var' ld3_`temp_var' 
    local indep_vars_lag `indep_vars' l_growth_quality_output_two_days
    local base_condition `base_condition_`j''
    

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
    local sum_row_lead "Sum of Lead Temperature Coefficents&"
    local pval_row_lead ""

    local sum_row_all "Sum of Temperature Coefficents&"
    local pval_row_all ""

    forvalues i=1/4 {

        reghdfe `dep_var' `indep_var_`i'' if `condition_`i'', `se_spec' 
            summ `dep_var' if e(sample) == 1 
            estadd scalar mean = r(mean) 
            * Store number of observations
            estadd scalar num_obs = e(N)
            * Store 
            estadd local dep_var_lag = "`dep_var_lag_`i''"
            * Check
        eststo model_`i'
                // Make sum of lead coefficients row
                local coeff_sum_lead
                foreach var in `indep_vars' {
                    local coeff_sum_lead `coeff_sum_lead' _b[`var'] + 
                }
                local coeff_sum_lead `coeff_sum_lead' 0 - _b[`temp_var']

                test `coeff_sum_lead' = 0 
                local p_value_lead_`i' = r(p) 
                local c_sum_lead_`i' = `coeff_sum_lead'
                // Add stars to coefficent
                add_stars `c_sum_lead_`i'' `p_value_lead_`i''
                local c_sum_lead_star_`i' `r(coeff_with_star)'
                local p_value_lead_`i' = string(`p_value_lead_`i'', "%5.3f")
                // Append coefficent sum row
                local sum_row_lead "`sum_row_lead' `c_sum_lead_star_`i'' &"
                // Append to p-value row
                local pval_row_lead "`pval_row_lead' & [`p_value_lead_`i'']"
            // Make sum of all temp coefficients row
                local coeff_sum_all
                foreach var in `indep_vars' {
                    local coeff_sum_all `coeff_sum_all' _b[`var'] + 
                }
                local coeff_sum_all `coeff_sum_all' 0
                test `coeff_sum_all' = 0 
                local p_value_all_`i' = r(p) 
                local c_sum_all_`i' = `coeff_sum_all'
                // Add stars to coefficent
                add_stars `c_sum_all_`i'' `p_value_all_`i''
                local c_sum_all_star_`i' `r(coeff_with_star)'
                local p_value_all_`i' = string(`p_value_all_`i'', "%5.3f")
                // Append coefficent sum row
                local sum_row_all "`sum_row_all' `c_sum_all_star_`i'' &"
                // Append to p-value row
                local pval_row_all "`pval_row_all' & [`p_value_all_`i'']"


    }

    local all_row "`sum_row_all' \\ `pval_row_all' \\ [0.5em]"
    local lead_row "`sum_row_lead' \\ `pval_row_lead' \\ [0.5em]"

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
            "num_obs Observations" 
            "r2 R-squared"
        ) 
        $esttab_opts keep(`temp_var');
        
	#delimit cr;

    insert_line `filename' 5 "`all_row'"
    insert_line `filename' 6 "`lead_row'"
    }
