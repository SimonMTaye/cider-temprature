/****************************************************************
****************************************************************
File:		2_growth_two_day.do
Purpose:	//TODO: Fill in


Author:		Isadora Frankenthal
Modified By:	Simon Taye
****************************************************************
****************************************************************/
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
            summ `dep_var' if e(sample) == 1 
            estadd scalar mean = r(mean) 
            * Store number of observations
            estadd scalar num_obs = e(N)
            estadd local dep_var_lag = "`dep_var_lag_`i''"
        eststo model_`i'
    }

    * Output table
	#delimit ;
    esttab * using "$output/tables/table_growth.tex", replace 
        scalars("dep_var_lag Control for Lag of Dep. Var" 
                "mean Dep. Var. Mean"
                "num_obs Observations" 
                "r2 R-squared") 
        mtitles("" "" "\shortstack{No Prior\\ Computer Experience}" "\shortstack{Computer Experience}") ///
        $esttab_opts keep(`indep_var_1') ;
        
	#delimit cr;