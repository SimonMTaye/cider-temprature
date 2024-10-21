	*************
	* TABLE A6  * 
	*************

*** Panel A 
clear 
	use "$dataset/school_test_scores_w_bl_replication.dta"




	// Table options for formatting, here to avoid duplication and make it easier to read / change
	#delimit ;
	local	table_opts starlevels(* 0.10 ** 0.05 *** 0.01) booktabs obslast  fragment
		mlabels("Grade" "Female" "Baseline Mean" "Baseline Decline", lhs("\hspace{2.5in} \textit{Covariate:}"))
		noobs nonotes compress b(%12.4f) se(%12.4f) nocons label; 
	#delimit cr ;

** Merge in covariates
	merge m:1 pid using "$dataset/baseline_covariates_replication.dta", gen(merge_baseline_cov)
** Merge in gender
	merge m:1 pid using  "$dataset/student_gender_with_pid_replication.dta", gen(merge_gender)

	drop if baseline==1

** Keep academic subjects
	drop if inlist(subject, "art", "computer", "evs", "mt", "ptyoga")

	keep if core==1

** Gen variables
	gen low_inc_school=(school=="glory"|school=="seiko")
	replace low_inc_school=. if school==""
	gen older=(class>=3)
	replace older=. if class==.
	
	gen school_inc=.
	replace school_inc=1 if school=="glory"
	replace school_inc=2 if school=="seiko"
	replace school_inc=3 if school=="pioneer suri" | school=="pioneer daniel"
	replace school_inc=4 if school=="asharfabad"
	replace school_inc=5 if school=="rn3"	
	
				
** Generating variables for when covariate is missing
	foreach interact in class female  bl_mean bl_dif {
		gen miss_`interact'=(`interact'==.)
		replace `interact'=0 if `interact'==.
	}

** Generating interaction variables
	foreach interact in class female  bl_mean bl_dif {
		gen treat_`interact'=treat*`interact'
		gen treat_miss_`interact'=treat*miss_`interact'
	}



** Hetero effects regs
	gen interact=.
	gen treat_interact=.
	gen miss_interact=.
	gen treat_miss_interact=.

	lab var treat "Cog. Practice"					
	lab var interact "Covariate"
	lab var treat_interact "Cog. Practice x Covariate"	
				
	local outcome "zscore"
	local treat "treat"
	local interact "interact treat_interact"
	local missing "miss_interact treat_miss_interact"
	local controls " i.sectionid baseline_z_all baseline_z_missing_all baseline_z baseline_z_missing "
	local cluster "pid"

	eststo clear

	local i = 1
	foreach var in    class female  bl_mean bl_dif {
		
			replace interact=`var'
			replace treat_interact=treat_`var'
			replace miss_interact=`var'
			replace treat_miss_interact=treat_miss_`var'

			eststo reg`i': reg `outcome' `treat' `interact' `controls' `missing' , vce( cl `cluster') 
					estadd scalar obs =   e(N)
					estadd scalar cluster =  e(N_clust) 
					lincom treat + treat_interact
					estadd scalar p = r(p)
					estadd local space = " "
		local i = `i' + 1
	}
	
	#delimit ;
		esttab reg*  using "$output/tables/table_a6.tex",
			keep( treat  treat_interact)  replace
			prehead("\begin{tabular}{l*{4}{c}} \multicolumn{5}{c}{\textbf{Panel A: School Tests}} \\ \toprule & \multicolumn{4}{c}{\textbf{Dependent Variable: Z-score of Student's Grades}} \\")
			postfoot("\bottomrule\\ \vspace{0.1in} \\")
			scalars( "p p-value: Cog. Practice" "space \hspace{0.4in}+ Cog. Practice x Covariate = 0" "obs Observations")  sfmt(%12.4f %12.4f %12.0f)
			`table_opts' ;
	#delimit cr ;
	
	
**** Panel B
	clear all
	use "$dataset/RCT_final_leave_one_out_replication.dta", clear

	
replace q_pct_corr_leave_out=0.4579099 if q_pct_corr_leave_out==.

** Gen variables
gen low_inc_school=(school=="glory"|school=="seiko")
	replace low_inc_school=. if school==""
gen older=(class>=4)
	replace older=. if class==.
	
gen school_inc=.
	replace school_inc=1 if school=="glory"
	replace school_inc=2 if school=="seiko"
	replace school_inc=3 if school=="pioneer suri" | school=="pioneer daniel"
	replace school_inc=4 if school=="asharfabad"
	replace school_inc=5 if school=="rn3"	

** Hetero effects regs
gen interact=.
gen treat_interact=.
gen decline_interact=.
gen decline_interact_treat=.
gen miss_interact=. 
gen treat_miss_interact=. 
gen decline_miss_interact=.
gen decline_miss_interact_treat=.

		
lab var treat "Cog. Practice"					
lab var interact "Covariate"
lab var treat_interact "Cog. Practice x Covariate"
lab var decline_interact "Predicted Decline x Covariate"
lab var treatXpred_dec_a6 "Cog. Practice x Predicted Decline"
lab var decline_interact_treat "Cog. Practice x Predicted Decline x Covariate"

	
local outcome "st_correct"
local controls "bl_all bl_all_miss mean_bl mean_bl_miss q_pct_corr_leave_out "
local levels "pred_dec_a6 interact treatXmath treatXlistening treatXravens"
local interactions "treatXpred_dec_a6 treat_interact decline_interact decline_interact_treat"
local missing "miss_interact treat_miss_interact decline_miss_interact decline_miss_interact_treat"	
local weight "pw2"
local absorb "question_id versionid sectionid"	
local cluster "pid"
local sample "if baseline==0"
	

eststo clear
	local i = 1
	foreach var in  class female  bl_mean bl_dif {
			replace interact=`var'
			replace treat_interact=treat_`var'
			replace decline_interact=decline_`var'
			replace decline_interact_treat=decline_`var'_treat

			replace miss_interact=miss_`var'
			replace treat_miss_interact=treat_miss_`var'
			replace decline_miss_interact=decline_miss_`var'
			replace decline_miss_interact_treat=decline_miss_`var'_treat			
			
			eststo reg`i': reghdfe `outcome'  `controls' `levels' `interactions' `missing' `sample' [pw=`weight'], vce(cl `cluster') a(`absorb') 
		
					estadd scalar obs = e(N)
					estadd scalar cluster = e(N_clust) 
					lincom treatXpred_dec_a6 + decline_interact_treat
					estadd scalar p = r(p)
					estadd local space = " "
					sum `outcome' if e(sample) == 1
					estadd scalar mean = r(mean)
		local i = `i' + 1
	}
	
	#delimit ;
			esttab reg*  using "$output/tables/table_a6.tex",  
					keep(treatXpred_dec_a6 decline_interact_treat)  append
					prehead("\multicolumn{5}{c}{\textbf{Panel B: Decline on Listening, Math and Ravens Tests}}\\ \toprule & \multicolumn{4}{c}{\textbf{Dependent Variable: 1[Question Correct]}} \\")
					postfoot("\bottomrule \end{tabular}")
					scalars("mean Dep. Var. Mean" "p p-value: Cog. Practice x Pred. Decline" "space \hspace{0.4in}+ Cog. Practice x Pred. Decline x Covariate = 0" "obs Observations") 
					`table_opts'  sfmt(%12.2f %12.4f %12.0f) ;
		#delimit cr ;


