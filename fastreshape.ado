*===============================================================================
* Program: fastreshape.ado
* Purpose: Quickly reshape datasets in Stata
* Author:  Michael Droste
*===============================================================================

program define fastreshape
version 13.1
syntax anything, i(string asis) j(string asis) [robust fast]

preserve

*-------------------------------------------------------------------------------
* Setup and error checking
*-------------------------------------------------------------------------------

gettoken rtype stubs : anything

* Make sure we are either reshaping long or wide
if "`rtype'"!="wide" & "`rtype'"!="long" {
	di "Error: Reshape type (`rtype') not wide or long, exiting."
	exit 1
}

* Make sure i variable exists
capture confirm variable `i'
if _rc!=0 {
	di "Error: i variable (`i') does not exist, exiting."
	exit 1
}

* Make sure j variable exists, if reshape wide
if "`rtype'"=="wide" {
	capture confirm variable `j'
	if _rc!=0 {
		di "Error: j variable (`j') does not exist, exiting."
		exit 1
	}
}

*-------------------------------------------------------------------------------
* Wide reshape
*-------------------------------------------------------------------------------

if "`rtype'"=="wide" {

	* Store number of obs and number of vars in long data
	local num_obs_long  = `=_N'
	local num_vars_long = `=c(k)'
	
	* Store unique values of j variable
	qui tabulate `j', matrow(unique_j)
	local num_j = rowsof(unique_j)
	forval z=1/`num_j' {
		local curr_j = unique_j[`z',1]
		local listj `listj' `curr_j'
	}
	di as text "(note: j = `listj')"
	
	* Store first, second, and last values of j
	local j1 = unique_j[1,1]
	if `num_j'>1 {
		local j2 = unique_j[2,1]
		if `num_j'>2 {
			local j3 = unique_j[`num_j',1]
		}
	}
	
	* Store distinct stub variables
	foreach v in `stubs' {
		capture describe `v', varlist
		local stub_vars `stub_vars' `=r(varlist)'
	}
	
	* Partition dataset by unique values of j variable
	forval z=1/`num_j' {
		local k = unique_j[`z',1]
		qui keep if `j'==`k'
		foreach v in `stubs' {
			rename `v' `v'`k'
		}
		qui drop `j'
		local fname temp_`z'
		tempfile `fname'
		qui save `fname', replace
		if `z'!=`num_j' {
			restore, preserve
		}
		if `z'==`num_j' {
			restore
		}
	}
	
	* Merge partitions together by observation
	qui use temp_1.dta, clear
	forval k=2/`num_j' {
		cap merge 1:1 `i' using temp_`k', nogen
		if _rc!=0 {
			noi di as error "Error: i (`i') not unique within j (`j')."
			exit 1
		}
	}
	
	* Format nicely
	local num_obs_wide = `=_N'
	local num_vars_wide = `=c(k)'
	sort `i'
	
	* Display output
	di ""
	di as text "Data" _col(28) %12s "long" _col(43) "->" _col(48) "wide"
	di as text "{hline 78}"
	di as text "Number of obs." _col(28) %12s "`num_obs_long'" _col(43) "->" _col(48) "`num_obs_wide'"
	di as text "Number of variables" _col(28) %12s "`num_vars_long'" _col(43) "->" _col(48) "`num_vars_wide'"
	di as text "j variable (`num_j' values)" _col(28) %12s "`j'"  _col(43) "->" _col(48) "(dropped)"
	di as text "xij variables:"
	foreach v in `stub_vars' {
		if `num_j'>2 {
			di as text _col(28) %12s "`v'" _col(43) "->" _col(48) "`v'`j1' `v'`j2' ... `v'`j3'"
		}
		else {
			di as text _col(28) %12s "`v'" _col(43) "->" _col(48) "`v'`j1' `v'`j2'"
		}
	}
	di as text "{hline 78}"

}

*-------------------------------------------------------------------------------
* Long reshape
* Kudos to http://www.nber.org/stata/efficient/reshape.html
*-------------------------------------------------------------------------------

if "`rtype'"=="long" {

	local num_obs_wide = `=_N'
	local num_vars_wide = `=c(k)'
	
	* Store distinct values of j across all stubs
	foreach v in `stubs' {
		local stub_vars_raw
		capture describe `v'*, varlist
		local stub_vars_raw `stub_vars_raw' `=r(varlist)'
		foreach v2 in `stub_vars_raw' {
			local c = subinstr("`v2'","`v'","",.)
			local stub_vars_clean `stub_vars_clean' `c'
		}
	} 
	mata: st_matrix("unique_j", uniqrows(strtoreal(tokens(st_local("stub_vars_clean")))'))
	local num_j = rowsof(unique_j)
	forval z=1/10 {
		local list_j `list_j' `=unique_j[`z',1]'
	}
	di "(note: j = `list_j')"
	
	* Write out a separate file for each value of j
	forval z=1/`num_j' {
		local c = unique_j[`z',1]
		local allstubs
		foreach s in `stubs' {
			local allstubs `allstubs' `s'`c'
		}
		keep `i' `allstubs'
		gen `j' = `c'
		rename *`c' *
		local fname temp`c'
		tempfile `fname'
		qui save `fname', replace
		if `z'!=`num_j' {
			restore, preserve
		}
		if `z'==`num_j' {
			restore
		}
	}
	
	* Concatenate temp files
	local c = unique_j[1,1]
	qui use temp`c', clear
	forval z=2/`num_j' {
		local c = unique_j[`z',1] 
		append using temp`c'
	}
	
	* Format nicely
	order `i', first
	order `j', after(`i')
	sort `i' `j'
	local num_obs_long = `=_N'
	local num_vars_long = `=c(k)'
	
	* Display output
	di ""
	di as text "Data" _col(28) %12s "wide" _col(43) "->" _col(48) "long"
	di as text "{hline 78}"
	di as text "Number of obs." _col(28) %12s "`num_obs_wide'" _col(43) "->" _col(48) "`num_obs_long'"
	di as text "Number of variables" _col(28) %12s "`num_vars_wide'" _col(43) "->" _col(48) "`num_vars_long'"
	di as text "j variable (`num_j' values)" _col(43) "->" _col(48) "`j'"
	di as text "xij variables:"
	foreach v in `stubs' {
		if `num_j'>2 {
			local j1 = unique_j[1,1]
			local j2 = unique_j[2,1]
			local j3 = unique_j[`num_j',1]
			di as text _col(2) %38s "`v'`j1' `v'`j2' ... `v'`j3'" _col(43) "->" _col(48) "`v'"
		}
		else {
			local j1 = unique_j[1,1]
			local j2 = unique_j[2,1]
			di as text _col(2) %38s "`v'`j1' `v'`j2'" _col(43) "->" _col(48) "`v'"
		}
	}
	di as text "{hline 78}"
}

*-------------------------------------------------------------------------------
* End
*-------------------------------------------------------------------------------

end
