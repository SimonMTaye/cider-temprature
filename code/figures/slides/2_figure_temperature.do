/****************************************************************
****************************************************************
File:		2_figure_temperature
Purpose:	Generate Temperature Figures

Author:	Simon Taye
****************************************************************
****************************************************************/

use "$data/generated/hi_hourly_temp_NOAA_indiatime.dta", clear

  set scheme plotplain

  egen date_group = group(day month year)
  egen daily_high = max(temperature_c), by(date_group)
  egen daily_low = min(temperature_c), by(date_group)

  egen monthly_high = mean(daily_high), by(month)
  label var monthly_high "Daily High"
  egen monthly_low = mean(daily_low), by(month)
  label var monthly_low "Daily Low"

  label var month "Month"


  twoway  ///
      (scatter monthly_high month, color(orange))  ///
      (scatter monthly_low month, color(eltblue)) ///
      , xlabel(1(1)12) xscale(r(1(1)12)) ytitle("Temperature", size(med)) xtitle("Month", size(med)) legend(position(6) rows(1) size(med)) 

  graph export "$output/figures/figure_temperature_monthly_slide.pdf", replace

  // Mean temperature is 28 (27.96..)
  replace time_india = time_india / 100

  egen mean_hourly = mean(temperature_c), by(time_india)
  gen color_condition = mean_hourly >= 29.4
  twoway  ///
      (scatter mean_hourly time_india if mean_hourly < 29.4, color(eltblue)) ///
      (scatter mean_hourly time_india if mean_hourly  >= 29.4, color(orange)) ///
      , xlabel(0(4)24) xscale(r(0(1)24)) ytitle("Temperature") yline(29.4) legend(off) xtitle("Hour")

  graph export "$output/figures/figure_temperature_hourly_slide.pdf", replace



