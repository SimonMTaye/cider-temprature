/****************************************************************
****************************************************************
File:		  1_10_absenteeism.do
Purpose:	Create dataset for absenteeism checks

Author:		Simon Taye
****************************************************************
****************************************************************/
  use "$data/raw/health_dataset.dta", clear  

    keep pid day_in_study date at_present_check

    gen day   = day(date)
    gen month = month(date)
    gen year  = year(date)

		merge m:1 day month year using "$data/generated/temperatue_lags.dta"
    drop if _merge == 2
    drop _merge
    
    merge 1:1 pid day_in_study using "$data/generated/hi_analysis_daily.dta", keepusing(checkin_time checkout_time hrs_of_work)
    drop if _merge == 2
    drop _merge

    // Merge computer
    preserve 
      use "$data/generated/hi_analysis_daily.dta", clear
      sort pid day_in_study
      collapse (first) computer, by(pid)
      tempfile computer
      save `computer'
    restore 

    merge m:1 pid using "`computer'", keepusing(computer)
    drop if _merge == 2
    drop _merge



  save "$data/generated/absenteeism_time_temp.dta", replace

