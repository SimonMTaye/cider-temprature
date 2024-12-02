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
    drop if max_absents == 1
    xtset pid two_days

    ereturn clear
    eststo clear

    local filename "$output/tables/table_growth_cutoff_changes.tex"

    local dep_var growth_quality_output_two_days
    local se_spec absorb(pid two_days month#year) cluster(pid)

    local temp_var temp_c_two_days

    // Macros for storing custom row to display coefficient sum
    local sum_row " Sum of Temperature Coefficents&"
    local pval_row ""
    local indep_var l_`dep_var' `temp_var' l1_`temp_var' l2_`temp_var'   l3_`temp_var'
    

    // I will decide the learning half cutoff
    forvalues i=5/12 {
        reghdfe `dep_var' `indep_var' if two_days > 2 & two_days <= `i', `se_spec' 
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
                if "`var'" != "l_growth_quality_output_two_days" {
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

        local custom_row "`sum_row' \\ `pval_row' \\ [0.5em] \hline"

        * Output table
        table_header  "\shortstack{Dependent Variable: \textbf{Productivity Growth}\\ N = Learning Half Cutoff}" 8
        local header prehead(`r(header_macro)')

        model_titles  "N = 5" "N = 6" "N = 7" "N = 8" "N = 9" "N = 10" "N = 11" "N = 12"
        local title `r(model_title)'
        // Cutting r2 from the table since it not consistent within the two panels
        #delimit ;
        esttab * using `filename', replace 
            nomtitle nonum `header' `title' 
            scalars(
                "dep_var_lag Control for Lag of Dependent Variable" 
                "mean Dependent Variable Mean"
                "num_obs Observations" 
                "r2 R-squared"
            ) 
            $esttab_opts keep(`temp_var');
        #delimit cr;



        // Insert manually constructed Sum of coefficent row at line 7 of the table
        insert_line `filename' 4 "`custom_row'"
    //nl (m_quality_output  = {b0} + {b1}*two_days + {b2}*max(0, day_in_study - {b3})), initial(b3 25) iterate(1000000)