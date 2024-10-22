/****************************************************************
****************************************************************
File:		2_helper.do
Purpose:	Helper programs and table configs all in spot

Author:		Simon Taye
****************************************************************
****************************************************************/

// For fragments only
global esttab_opts_fragment label nonote noobs nodepvars nocons se nomtitle
// For all other tables
global esttab_opts $esttab_opts_fragment prefoot("[0.5em] \hline") postfoot("\bottomrule \end{tabular}}")

cap program drop table_header
program define table_header, rclass
    // Define the parameters
    args header_text num_columns
    
    // Create the range for cmidrule
    local start_col 2
    local end_col = `num_columns' + 1
    
    // Construct the prehead string
    local header_string "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} {\begin{tabular}{l*{`end_col'}{c}} \toprule & \multicolumn{`num_columns'}{c}{`header_text'} \\ \cmidrule(lr){`start_col'-`end_col'}"
    
    // Return the result in a local macro accessible to the caller
    return local header_macro "`header_string'"
end

cap program drop model_titles
program define model_titles, rclass
    // Define the parameters
    syntax anything(name=group_labels) [, pattern(string)]
    
    // Count the number of labels (split by space)
    local num_labels : word count `group_labels'
    
    // Construct the pattern with the correct number of 1s
    // Check if the pattern option is specified
    if "`pattern'" == "" {
        // Construct the pattern with the correct number of 1s
        local pattern_str ""
        forval i = 1/`num_labels' {
            local pattern_str `pattern_str' 1
        }
    }
    else {
        // Use the user-specified pattern
        local pattern_str `pattern'
    }
    // Construct the mgroups command dynamically
    local mgroups_cmd mgroups(`group_labels', pattern(`pattern_str') span prefix(\multicolumn{@span}{c}{) suffix(}))
    
    // Store the constructed command in an r-class macro
    return local model_title `mgroups_cmd'
end

