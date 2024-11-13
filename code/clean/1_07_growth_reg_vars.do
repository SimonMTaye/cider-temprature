/***************************************************************
****************************************************************
File:		1_7_growth_reg_vars
Purpose:	Create two day vars and others needed for new growth
            regressions

Author:		Isadora Frankenthal

Modified By:	Simon Taye

Note:		sep24 learning with growth rates
****************************************************************
****************************************************************/
use "$data/generated/hi_analysis_daily.dta", clear  
    sort pid day_in_study

    * Mark absentees
    gen one = 1 if day_in_study<15
    egen count = sum(one), by (pid)
    gen absents = 1 if count<12 
    egen max_absents = max(absents), by(pid)

    * generate two day lags and leads, taking average over the past two days
    forvalues i=1/5 {
        local j = (`i' * 2) 
        local k = `j' - 1
        gen l`i'_temp_c_two_days = (l`j'_temperature_c + l`k'_temperature_c)/2
        gen ld`i'_temp_c_two_days = (ld`j'_temperature_c + ld`k'_temperature_c)/2
        gen l`i'_temp_c_two_days_workday = (l`j'_workday_temperature_c + l`k'_workday_temperature_c)/2
        gen ld`i'_temp_c_two_days_workday = (ld`j'_workday_temperature_c + ld`k'_workday_temperature_c)/2
    }

        
    /* Computer related code 
    a23: Have you used a computer before?
    a24: How profficent are you
    */
    egen computer = max(a23), by(pid)
    replace computer = 0 if a24==1 

    gen english = a15

    * Define two day periods
    gen two_days = 1 if inrange(day_in_study, 1, 2)
    replace two_days = 2 if inrange(day_in_study, 3, 4)
    replace two_days = 3 if inrange(day_in_study, 5, 6)
    replace two_days = 4 if inrange(day_in_study, 7, 8)
    replace two_days = 5 if inrange(day_in_study, 9, 10)
    replace two_days = 6 if inrange(day_in_study, 11, 12)
    replace two_days = 7 if inrange(day_in_study, 13, 14)
    replace two_days = 8 if inrange(day_in_study, 15, 16)
    replace two_days = 9 if inrange(day_in_study, 17, 18)
    replace two_days = 10 if inrange(day_in_study, 19, 20)
    replace two_days = 11 if inrange(day_in_study, 21, 22)
    replace two_days = 12 if inrange(day_in_study, 23, 24)
    replace two_days = 13 if inrange(day_in_study, 25, 26)
    replace two_days = 14 if inrange(day_in_study, 27, 28)

    gen first_half = day_in_study <= 14

    * mean output/temp every two days 
    egen quality_output_two_days = mean(m_quality_output), by(pid two_days)
    egen temp_c_two_days = mean(temperature_c), by(pid two_days)
    egen temp_c_two_days_workday = mean(workday_temperature_c), by(pid two_days)


save "$data/generated/hi_analysis_daily.dta", replace

    * Generate two-day period dta
    collapse first_half quality_output_two_days temp_c_two_days temp_c_two_days_workday  l* (firstnm) max_absents computer english month year, by(pid two_days)

    forvalues i=1/5 {
        label var l`i'_temp_c_two_days "Lag `i' of Temperature"
        label var ld`i'_temp_c_two_days "Lead `i' of Temperature"
        label var l`i'_temp_c_two_days_workday "Lag `i' of Temperature"
        label var ld`i'_temp_c_two_days_workday "Lead `i' of Temperature"
    }

    drop if two_days == .

    gen learning_half = two_days < 9
    label var learning_half "Dummy indicating whether we are in period where learning happens or not"

    sort pid two_days
    xtset pid two_days

    gen diff_quality_output_two_days = quality_output_two_days - quality_output_two_days[_n-1]
    replace diff_quality_output_two_days = quality_output_two_days - quality_output_two_days[_n-2] if diff_quality_output_two_days == .
     
    replace diff_quality_output_two_days=. if two_days==1
    gen growth_quality_output_two_days = diff_quality_output_two_days/ quality_output_two_days[_n-1]
    gen l_growth_quality_output_two_days = l.growth_quality_output_two_days 
    replace l_growth_quality_output_two_days = l2.growth_quality_output_two_days if missing(l_growth_quality_output_two_days) 
    
    label var growth_quality_output_two_days "Productivity growth"
    label var temp_c_two_days         "Temperature ($^{\circ}C$)"
    label var temp_c_two_days_workday "Temperature ($^{\circ}C$)"

save "$data/generated/hi_analysis_twoday.dta", replace  