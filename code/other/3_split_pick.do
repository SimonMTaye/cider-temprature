/****************************************************************
****************************************************************
File:		3_split_pick.do
Purpose:	Determiens the best point to do a  split based on the AIC 
          and BIC criteria

Author:		Simon Taye
****************************************************************
****************************************************************/
	
use "$data/generated/hi_analysis_daily.dta", clear 

    local output_var m_quality_output
    local period day_in_study

    // Counter macro
    local i 0

    forvalues knot=2/30 {
        local i = `i' + 1
        * Generate spline variables with knot at `knot'
        mkspline day_1 `knot' day_2 = `period'
        * Regress output_var on spline variables
        quietly regress `output_var' day_1 day_2
        * Store AIC, BIC, and knot position
        local knot_`i' = `knot'
        local rss_`i' = e(rss)
        drop day_1 day_2
    }

    // Clear dataset
    di "i is:   `i'"
    clear frames
    di "i is:   `i'"
    set obs `i'
    gen knot = .
    gen rss = .

    forvalues j = 1 / `i' {
      replace knot = `knot_`j'' in `j'
      replace rss = `rss_`j'' in `j'
    }

    save "$data/generated/knot_rss_r2.dta", replace

    * Find the knot position with the lowest AIC
    sort rss
    list knot rss in 1
    scalar best_knot = knot[1]
    display "Best knot position based on RSS is at day = " best_knot