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
    
    eststo clear

    drop if max_absents == 1

    xtset pid two_days


    local dep_var growth_quality_output_two_days
    local se_spec absorb(pid two_days month#year) cluster(pid)

    local condition_1 two_days<8
    local indep_var_1 temp_c_two_days
    local dep_var_lag_1 "No"

    local condition_2 `condition_1'
    local indep_var_2 temp_c_two_days l.growth_quality_output_two_days
    local dep_var_lag_2 "Yes"

    local condition_3 two_days<8 & computer==0
    local indep_var_3 `indep_var_2'
    local dep_var_lag_3 "Yes"

    local condition_4 two_days<8 & computer==1
    local indep_var_4 `indep_var_2'
    local dep_var_lag_4 "Yes"

    * Run regression based on specification defined in macros above
    forvalues i=1/4 {
        reghdfe `dep_var' `indep_var_`i'' if `condition_`i'', `se_spec'
            summ `dep_var' //if e(sample) == 1 
            estadd scalar mean = r(mean) 
            * Store number of observations
            estadd scalar num_obs = e(N)
            estadd local dep_var_lag = "`dep_var_lag_`i''"
        eststo model_`i'
    }

    * Output table
	#delimit ;
    esttab * using "$output/tables/table_growth_w_lag.tex", replace 
        fragment nomtitle
		prehead("\begin{tabular}{l*{4}{c}} \toprule & \multicolumn{4}{c}{Dependent Variable: \textbf{Productivity Growth}} \\[0.5em]")
		posthead("\hline \\ \hspace{2mm} \textit{Panel A: No lags} & & & &\\[0.5em]")
        mgroups("Full Sample" "\shortstack{No Prior\\ Computer Experience}" "\shortstack{Computer Experience}", 
            pattern(1 0 1 1)
            prefix(\multicolumn{@span}{c}{) suffix(})
            span erepeat(\cmidrule(lr){@span})) 
        $esttab_opts_fragment keep(`indep_var_1') ;
        
	#delimit cr;

/// Panel B -> Lag
    eststo clear
    // Define regression specifications here
    //  * dep_var -> dependent variable which is constant for all regs
    //  * se_spec -> clustering and FE which is constant

    //  * condition_`i' -> Sample condition for regression i
    //  * indep_var_`i' -> Explanatory variable for regression i
    //  * dep_var_lag_`i' -> Indicator for whether regression i controls for lagged depedent variable

    local dep_var growth_quality_output_two_days
    local se_spec absorb(pid two_days month#year) cluster(pid)

    local condition_1 two_days>2 & two_days<8
    local indep_var_1 temp_c_two_days l1_temp_c_two_days l2_temp_c_two_days l3_temp_c_two_days 
    local dep_var_lag_1 "No"

    local condition_2 `condition_1'
    local indep_var_2 `indep_var_1' l.growth_quality_output_two_days
    local dep_var_lag_2 "Yes"

    local condition_3 two_days>2 & two_days<8 & computer==0 
    local indep_var_3 `indep_var_2'
    local dep_var_lag_3 "Yes"

    local condition_4 two_days>2 & two_days<8 & computer==1 
    local indep_var_4 `indep_var_2'
    local dep_var_lag_4 "Yes"

    xtset pid two_days

    // Macros for storing custom row to display coefficient sum
    local sum_row "[1em] Sum of Temperature Coefficents&"
    local pval_row "&"

    forvalues i=1/4 {
        reghdfe `dep_var' `indep_var_`i'' if `condition_`i'', `se_spec' 
            summ `dep_var' if e(sample) == 1 
            estadd scalar mean = r(mean) 
            * store number of observations
            estadd scalar num_obs = e(N)
            * store lagged exists indicator
            estadd local dep_var_lag = "`dep_var_lag_`i''"
            * Store sum of temp coeffcients and p-value 
            local coeff_sum _b[temp_c_two_days] + _b[l1_temp_c_two_days] + _b[l2_temp_c_two_days] + _b[l3_temp_c_two_days]
            // local c_sum_`i' = `coeff_sum' -> will use when constructing custom row
            test  `coeff_sum' = 0 
            // local p_value_`i' = r(p) -> will use when constructing custom row
            *  Add coeff sum and scalar to output
            estadd scalar c_sum = `coeff_sum'
            estadd scalar p_value = r(p) 
        eststo model_`i'
        // Construct custom row for displaying coeff_sum and p-value
        local sum_row "`sum_row' `c_sum_`i'' &"
        local pval_row "`pval_row' [`p_value_`i''] &"
    }

    local custom_row "`sum_row' \\ `pval_row'"

    // Cutting r2 from the table since it not consistent within the two panels
	#delimit ;
    esttab * using "$output/tables/table_growth_w_lag.tex", append 
        fragment nomtitle nonum
		posthead("\hspace{2mm} \textit{Panel B: Temprature Lags} & & & &\\[0.5em]")
        scalars(
            "c_sum Sum of Temperature Coefficents"
            "p_value p-value for Temperature Coefficents = 0"
            "dep_var_lag Control for Lag of Dependent Variable" 
            "mean Dependent Variable Mean"
            "num_obs Observations" 
        ) 
        $esttab_opts keep(`indep_var_1') ;
	#delimit cr;
