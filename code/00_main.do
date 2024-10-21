/****************************************************************
****************************************************************
File:		00_main
Purpose:	Setup paths and install required packages
        

Author:		Simon Taye
****************************************************************
****************************************************************/

    

// Set path variables
    // Set root path correctly
    //local cwd : pwd
    // global root "`cwd'/.."
    global root "/Users/st2246/Work/Temperature"
    cd $root

    global data "$root/data"
    global output "$root/output"
    global adodir "$root/external/ado"

    
    // Make empty directories that may not exist already
    cap mkdir "$data/generated"
    cap mkdir "$output"
    cap mkdir "$output/figures"
    cap mkdir "$output/tables"

    

// Dependency Handling: Ensure all external packages needed are stored
//      alongside the do files

    // Remove non system adodirs
    tokenize `"$S_ADO"', parse(";")
    while `"`1'"' != "" {
        if (`"`1'"'!="BASE") & (`"`1'"'!="SITE") cap adopath - `"`1'"'
        macro shift
    }
    // Set adoplus manually
    sysdir set PLUS "$adodir"
    adopath ++ PLUS

// Flags for running cdoe
//      cleaning_dos generates generated data from raw data
local cleaning_dos 0
//      tables runs code to generate all tables
local tables 1
//      figures runs code to generate all figures
local figures 0

// temp macro for running new tables
local new_tables 0
//      set custom figure scheme
set scheme eop

// Raw Data: If first time cloning repository, make sure to extract
//      raw data from zip
    if !fileexists("$data/raw") {
        if fileexists("$data/raw.zip") {
            cd "$data"
            unzipfile "$data/raw.zip",  replace 
            cd "$root/code"
        } 
        else {
            display "Raw data missing"
        }
    }

*** Runing cleaning do files
    if `cleaning_dos' == 1 {
        do "$root/code/clean/1_1_temp.do"
        do "$root/code/clean/1_2_join_temp_prod.do"
        do "$root/code/clean/1_3_merge_lags_baseline.do"
        do "$root/code/clean/1_4_merge_pollution.do"
        do "$root/code/clean/1_5_intermediate_vars.do"
        do "$root/code/clean/1_6_merge_cog_ab.do"
        do "$root/code/clean/1_7_growth_reg_vars.do"
    }



    if `figures' == 1 {
        // INFO: Orginially named 'learning.do'
        do "$root/code/figures/2_figure_1.do"
        // INFO: Orginially part of learning with temp bins.do
        do "$root/code/figures/2_figure_2.do"
        // INFO: Orignially part of productivity.do
        do "$root/code/figures/2_figure_a2.do"
    }


// esttab options for tweaking output

    if `tables' == 1 {
        do "$root/code/tables/2_helper.do"
        do "$root/code/tables/2_table_1.do"
        // INFO: Orginially named 'learning.do'
        *do "$root/code/tables/2_table_2.do"
        do "$root/code/tables/2_table_3.do"
        // INFO: Orignially part of productivity.do
        do "$root/code/tables/2_table_a1.do"
        do "$root/code/tables/2_table_a2.do"
        *do "$root/code/tables/2_table_a3.do"
        do "$root/code/tables/2_table_a4.do"
        // INFO: Orginially part of learning with temp bins.do
        do "$root/code/tables/2_table_a5.do"
        // INFO: Orginially part of abseentism.do
        do "$root/code/tables/2_table_a6.do"
        // INFO: Orginially part of coginition.do
        do "$root/code/tables/2_table_a7.do"
        // INFO: Orginially part of learning.do
        do "$root/code/tables/2_table_a8.do"
        do "$root/code/tables/2_table_a9.do"
        // INFO: Orginially named 'learning growth rates.do'
        do "$root/code/tables/2_table_a10.do"
        // INFO: Originally from "balance.do"
        do "$root/code/tables/2_table_a11.do"
    }


    if `new_tables' == 1 {
        do "$root/code/tables/2_helper.do"
        do "$root/code/2_growth_two_day_temp_lag.do"
        do "$root/code/2_growth_two_day_temp_lead.do"
        do "$root/code/2_productivity_lag.do"
    }


