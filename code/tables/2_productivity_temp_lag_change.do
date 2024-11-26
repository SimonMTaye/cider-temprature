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

    ereturn clear
    eststo clear

    local filename "$output/tables/table_productivity_lag_changes.tex"

    local dep_var m_quality_output
    local se_spec absorb(pid day_in_study month#year) cluster(pid)

    local temp_var temperature_c

    // Macros for storing custom row to display coefficient sum
    local sum_row " Sum of Temperature Coefficents&"
    local pval_row ""

    // Generate dependent variable lags back filling to two-days ago if yesterday is missing
    gen l_`dep_var' = l.`dep_var'
    replace l_`dep_var' = l2.`dep_var' if missing(l_`dep_var')


    forvalues i=0/10 {
        local indep_var `temp_var'
        // Add j number of lags
        forvalues j=1/`i' {
            local indep_var `indep_var' l`j'_`temp_var'
        }
        reghdfe `dep_var' l_`dep_var' `indep_var' , `se_spec' 
            summ `dep_var' if e(sample) == 1 
            estadd scalar mean = r(mean) 
            * store number of observations
            estadd scalar num_obs = e(N)
            * store lagged exists indicator
            estadd local dep_var_lag = "Yes"
            * Store sum of temp coeffcients and p-value 
            eststo model_`i'
            local coeff_sum
            foreach var in `indep_var' {
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

        local custom_row "`sum_row' \\ `pval_row' \\ [0.5em] \hline"

        * Output table
        table_header  "Dependent Variable: \textbf{Productivity}" 11
        local header prehead(`r(header_macro)')

        model_titles  "N = 0" "N = 1" "N = 2" "N = 3" "N = 4" "N = 5" "N = 6" "N = 7" "N = 8" "N = 9" "N = 10" , und
        local title `r(model_title)'
        // Cutting r2 from the table since it not consistent within the two panels
        #delimit ;
        esttab * using `filename', replace 
            nomtitle num `header' `title' 
            scalars(
                "dep_var_lag Control for Lag of Dependent Variable" 
                "mean Dependent Variable Mean"
                "num_obs Observations" 
                "r2 R-squared"
            ) 
            $esttab_opts keep(`temp_var');
        #delimit cr;



        // Insert manually constructed Sum of coefficent row at line 7 of the table
        insert_line `filename' 5 "`custom_row'"
    //nl (m_quality_output  = {b0} + {b1}*two_days + {b2}*max(0, day_in_study - {b3})), initial(b3 25) iterate(1000000)