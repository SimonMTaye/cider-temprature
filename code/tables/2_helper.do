/****************************************************************
****************************************************************
File:		2_helper.do
Purpose:	Helper programs and table configs all in spot

Author:		Simon Taye
****************************************************************
****************************************************************/

global esttab_opts label nonote noobs nodepvars nocons se nomtitle

cap program drop table_header
program define table_header, rclass
    // Define the parameters
    args header_text num_columns
    
    // Create the range for cmidrule
    local start_col 2
    local end_col = `num_columns' + 1
    
    // Construct the prehead string
    local header_string "{\begin{tabular}{l*{`end_col'}{c}} \toprule & \multicolumn{`num_columns'}{c}{`header_text'} \\ \cmidrule(lr){`start_col'-`end_col'}"
    
    // Return the result in a local macro accessible to the caller
    return local header_macro "`header_string'"
end

cap program drop model_titles
program define model_titles, rclass
    // Define the parameters
    syntax anything(name=group_labels)
    
    // Count the number of labels (split by space)
    local num_labels : word count `group_labels'
    
    // Construct the pattern with the correct number of 1s
    local pattern_str = ""
    forval i = 1/`num_labels' {
        local pattern_str `pattern_str' 1
    }
    
    // Construct the mgroups command dynamically
    local mgroups_cmd mgroups(`group_labels', pattern(`pattern_str') prefix(\multicolumn{1}{c}{) suffix(}))
    
    // Store the constructed command in an r-class macro
    return local model_title `mgroups_cmd'
end

