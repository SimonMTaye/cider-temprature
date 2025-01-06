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

// Load helper scripts with custom programs
do "$root/code/run_recursive.do"
do "$root/code/table_helpers.do"

//      set custom figure scheme
set scheme eop

// Flags for running cdoe
//      cleaning_dos generates generated data from raw data
local cleaning_dos      1
//      generate figures and tables used in slides (2024-11)
local slides            1
// run other code
local other             1
// run code for generating figures and tables in old draft (2024-08)
local old_draft         1

local new_tables        1
local new_figures       1


*** Runing cleaning do files
    // NOTE: run_dofiles doesn't sort files when running so run cleaning do files manually 
    if `cleaning_dos' == 1 {
        do "$root/code/clean/1_01_temp.do"
        do "$root/code/clean/1_02_join_temp_prod.do"
        do "$root/code/clean/1_03_merge_baseline_gen_lags.do"
        do "$root/code/clean/1_04_merge_pollution.do"
        do "$root/code/clean/1_05_intermediate_vars.do"
        do "$root/code/clean/1_06_merge_cog_ab.do"
        do "$root/code/clean/1_07_growth_reg_vars.do"
        do "$root/code/clean/1_08_absenteeism.do"
    }
    
    if `slides' == 1 {
        run_dofiles $root/code/slide
    }

    if `new_tables' == 1 {
        run_dofiles $root/code/tables
    }

    if `new_figures' == 1 {
        //run_dofiles "$root/code/old_draft"
    }
    

    if `old_draft' == 1 {
        run_dofiles $root/code/old_draft
    }

    if `other' == 1 {
        run_dofiles $root/code/other
    }

    
