/****************************************************************
****************************************************************
File:		2_helper.do
Purpose:	Helper programs and table configs all in spot

Author:		Simon Taye
****************************************************************
****************************************************************/

// For fragments only
global esttab_opts_fragment label nonote noobs nodepvars nocons se nomtitle star(* 0.10 ** 0.05 *** 0.010)
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
    syntax anything(name=group_labels) [, pattern(string) Underline]
    
    // Count the number of labels (split by space)
    local num_labels : word count `group_labels'
    
    local underline_cmd 
    if !missing("`underline'") {
        local underline_cmd erepeat(\cmidrule(lr){@span})
    }
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
    local mgroups_cmd mgroups(`group_labels', pattern(`pattern_str') span prefix(\multicolumn{@span}{c}{) suffix(}) `underline_cmd')
    
    // Store the constructed command in an r-class macro
    return local model_title `mgroups_cmd'
end

cap program drop insert_line
program define insert_line
    // Program to insert a line into a file at a specific line number
    // Usage: insert_line filename linenum "text_to_insert"

    // Capture the arguments: filename, line number, and text to insert
    args filename linenum line_text
    local linenum = real("`linenum'")

	// Specify file paths
	// Open input file for reading
	file open fin using "`filename'", read text
    tempfile temp_file
	file open fout using "`temp_file'", write replace text


	// Read the input file line by line
	file read fin doc_line
	// Initialize line counter
	local line_counter 1

	while (`r(eof)' == 0) {
			// If the current line is the line where we want to insert text, write the new text
            if `line_counter' == `linenum' {
                file write fout "`line_text'" _n
            }
	        file write fout "`doc_line'" _n
			file read fin doc_line
			// Increment the line counter
			local line_counter = `line_counter' + 1
	}
	file write fout "`doc_line'" _n

	// Close the input and output files
	file close fin
	file close fout

    copy "`temp_file'" "`filename'", replace

end

cap program drop delete_line
program define delete_line
    // Program to insert a line into a file at a specific line number
    // Usage: insert_line filename linenum "text_to_insert"

    // Capture the arguments: filename, line number, and text to insert
    args filename linenum 
    local linenum = real("`linenum'")

	// Specify file paths
	// Open input file for reading
	file open fin using "`filename'", read text
    tempfile temp_file
	file open fout using "`temp_file'", write replace text


	// Read the input file line by line
	file read fin doc_line
	// Initialize line counter
	local line_counter 1

	while (`r(eof)' == 0) {
			// If the current line is the line where we want to insert text, write the new text
            if `line_counter' != `linenum' {
                file write fout "`doc_line'" _n
            }
            file read fin doc_line
			// Increment the line counter
			local line_counter = `line_counter' + 1
	}
	file write fout "`doc_line'" _n

	// Close the input and output files
	file close fin
	file close fout

    copy "`temp_file'" "`filename'", replace

end


cap program drop add_stars
program define add_stars, rclass
    // Capture the arguments: filename, line number, and text to insert
    args coefficient p_value_str
    if missing(`coefficient') | missing(`p_value_str') {
        display as error "Missing coefficent or p-value"
        exit
    }

    local coefficient = real("`coefficient'")

    local p_value = real("`p_value_str'")
    local stars ""
    if `p_value' <= 0.1 {
        local stars "\sym{*}"
    }

    if `p_value' <= 0.05 {
        local stars "\sym{**}"
    }

    if `p_value' <= 0.01 {
        local stars "\sym{***}"
    }

    local coef_str = string(`coefficient', "%10.4f")

    // Return coefficent string with stars
    return local coeff_with_star "`coef_str'`stars'"
end
