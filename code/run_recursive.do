/*************************************************************************
   This script defines a program that:
   1) Takes a directory as input,
   2) Finds all .do files in that directory,
   3) Runs them,
   4) Recursively repeats for all subdirectories.

   Usage in Stata (after saving this script):
   . do run_all_dofiles "C:\path\to\your\directory"
*************************************************************************/

/* Program definition: run_dofiles */
capture program drop run_dofiles
program define run_dofiles

    /*********************************************************************
      Syntax: 
         run_dofiles [directory]

      The program will:
      1) Run all .do files in the specified directory,
      2) Recursively call itself on all subdirectories.
    *********************************************************************/

    syntax anything(name=dir)

    /* Make sure we have quotes around the directory path (in case of spaces). */

    local dofiles : dir "`dir'" files "*.do"

    /* 2) Run each .do file */
    foreach f of local dofiles {
        do "`dir'/`f'"
    }

    /* 3) Recursively search subdirectories */
    local subdirs : dir "`dir'"  dirs "*"
    foreach sd of local subdirs {
        /* Call run_dofiles recursively on each subdirectory */
        run_dofiles `dir'/`sd'
    }
end