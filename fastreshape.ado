*===============================================================================
* Program: fastreshape.ado
* Purpose: Quickly reshape datasets in Stata
* Version: 0.2 (2018/01/13)
* Author:  Michael Droste
* Website: http://www.github.com/mdroste/stata-fastreshape
*===============================================================================

program define fastreshape
version 13.1
syntax anything, [i(string asis) j(string asis) robust fast string verbose]

*-------------------------------------------------------------------------------
* Setup
*-------------------------------------------------------------------------------

* Preserve dataset in case of failure
preserve

* Parse input
gettoken rtype stubs : anything


*-------------------------------------------------------------------------------
* Exception handling
*-------------------------------------------------------------------------------

* If j not specified and i is, then j should be _j
if "`i'"!="" & "`j'"=="" {
	local j _j
}

* Make sure we are either reshaping long or wide
if "`rtype'"!="wide" & "`rtype'"!="long" {
	di "Error: Reshape type (`rtype') not wide or long, exiting."
	exit 1
}

* Handle implicit syntax
if "`stubs'"=="" & "`i'"=="" & "`j'"=="" {
	local m1: char  _dta[ReS_stubs]
	local m2: char  _dta[ReS_i]
	local m3: char  _dta[ReS_j]
	if "`m1'"=="" & "`m2'"=="" & "`m3'"=="" {
		di as error "Error: data has not been reshaped yet. The implicit syntax only works if you have reshaped the data in memory already."
		exit 1
	}
	else {
		local stubs `m1'
		local i `m2'
		local j `m3'
	}
}

* Make sure i variable exists
if "`i'"!="" {
	capture confirm variable `i'
	if _rc!=0 {
		di as error "Error: i variable (`i') does not exist, exiting."
		exit 1
	}
}

* If reshape wide, make sure j variable exists
if "`j'"!="" {
	if "`rtype'"=="wide" {
		capture confirm variable `j'
		if _rc!=0 {
			di as error "Error: j variable (`j') does not exist, exiting."
			exit 1
		}
	}
}

* If reshape long, make sure j variable does NOT already exist
if "`rtype'"=="long" {
	capture confirm variable `j'
	if _rc==0 {
		di as error "Error: j variable (`j') already exists, exiting."
		exit 1
	}
}

* If i not specified, exit (unless implicit usage of reshape)
if "`i'"=="" {
	di as error "Error: i variable not specified, exiting."
	exit 1
}

* If reshape long, make sure i variable uniquely identifies observations
if "`rtype'"=="long" {
	tempvar ni
	bysort `i': gen `ni' = _n
	qui sum `ni'
	if r(max)>1 {
		di as error "Error: i does not uniquely identify observations, which it should when reshaping long."
		exit 1
	}
	drop `ni'
}

* Check type of j, set string option if string
cap confirm string variable `j'
if _rc==0 {
	if "`string'"=="" {
		di "Warning: the string option was not specified, but the j variable (`j') is a string."
		local string "string"
	}
}

*-------------------------------------------------------------------------------
* Prep for reshape (long and wide)
*-------------------------------------------------------------------------------



*-------------------------------------------------------------------------------
* Wide reshape
*-------------------------------------------------------------------------------

* If reshape wide...
if "`rtype'"=="wide" {

	* Store number of obs and number of vars in long data
	local num_obs_long  = `=_N'
	local num_vars_long = `=c(k)'
	
	* @ functionality for stubs
	foreach v in `stubs' {
		local c = "`v'"
	    local wildcard_pos = strpos("`c'","@")
		local string_len = strlen("`c'")
		if `wildcard_pos'>0 {
			* When @ symbol is in the middle of the string
			if `wildcard_pos'>1 & `wildcard_pos'<`string_len' {
				local c1 = substr("`c'",1,`wildcard_pos'-1) + "*" + substr("`c'",`wildcard_pos'+1,.)
				local c2 = substr("`c'",1,`wildcard_pos'-1) + substr("`c'",`wildcard_pos'+1,.) + "*"
				local c3 = substr("`c'",1,`wildcard_pos'-1) + substr("`c'",`wildcard_pos'+1,.)
				local stubs2 `stubs2' `c3'
			}
			* When @ symbol is at the end of the string
			if `wildcard_pos'==`string_len' {
				local c3 = substr("`c'",1,`wildcard_pos'-1)
				local stubs2 `stubs2' `c3'
			}
			* When @ symbol is at the beginning of the string
			if `wildcard_pos'==1 {
				local c1 = "*" + substr("`c'",`wildcard_pos'+1,.)
				local c2 = substr("`c'",`wildcard_pos'+1,.) + "*"
				local c3 = substr("`c'",`wildcard_pos'+1,.)
				local stubs2 `stubs2' `c3'
			}
		}
		else {
			local stubs2 `stubs2' `c'
		}
	}
	local old_stubs `stubs'
	local stubs `stubs2'
	
	* Store unique values of j variable (non-string)
	if "`verbose'"!="" timer on 1
	if "`string'"=="" {
		qui tabulate `j', matrow(unique_j)
		local num_j = rowsof(unique_j)
		forval z=1/`num_j' {
			local curr_j = unique_j[`z',1]
			local listj `listj' `curr_j'
		}
		di as text "(note: j = `listj')"
		local j1 = unique_j[1,1]
		if `num_j'>1 {
			local j2 = unique_j[2,1]
			if `num_j'>2 {
				local j3 = unique_j[`num_j',1]
			}
		}
	}
	
	* Store unique values of j variable (string)
	if "`string'"!="" {
		qui levelsof `j', local(unique_j)
		local num_j = 0
		foreach c in `unique_j' {
			local num_j = `num_j'+1
			local listj `listj' `c'
			local unique_j`num_j' "`c'"
		}
		di as text "(note: j = `listj')"
		local j1 "`unique_j1'"
		local j2 "`unique_j2'"
		local j3 "`unique_j`num_j''"
	}
	
	* Store distinct stub variables
	foreach v in `stubs' {
		capture describe `v', varlist
		local stub_vars `stub_vars' `=r(varlist)'
	}
	if "`verbose'"!="" timer off 1
	
	* XX need to identify all variables in dataset NOT i, j, stub
	if "`verbose'"!="" timer on 2
	//di "stub_vars: `stub_vars' `i' `j'"
	qui ds `stub_vars' `i' `j', not
	if "`verbose'"!="" timer off 2
	
	* XX make sure the variables above are constant within
	
	* Partition dataset by unique values of j variable
	if "`verbose'"!="" timer on 3
	forval z=1/`num_j' {
		if "`string'"=="" {
			local k = unique_j[`z',1]
			qui keep if `j'==`k'
		}
		else {
			local k "`unique_j`z''"
			qui keep if `j'=="`k'"
		}
		foreach v in `stubs' {
			rename `v' `v'`k'
		}
		qui drop `j'
		tempfile temp_`z'
		qui save `temp_`z'', replace
		if `z'!=`num_j' {
			restore, preserve
		}
		if `z'==`num_j' {
			restore
		}
	}
	if "`verbose'"!="" timer off 3
	
	* Merge partitions together by observation
	if "`verbose'"!="" timer on 4
	qui use `temp_1', clear
	forval k=2/`num_j' {
		cap merge 1:1 `i' using `temp_`k'', nogen
		if _rc!=0 {
			noi di as error "Error: i (`i') not unique within j (`j')."
			exit 1
		}
	}
	if "`verbose'"!="" timer off 4
	
	* For wide reshapes, rename @ variables now
	foreach v in `old_stubs' {
		local c = "`v'"
	    local wildcard_pos = strpos("`c'","@")
		local string_len = strlen("`c'")
		if `wildcard_pos'>0 {
			* When @ symbol is in the middle of the string
			if `wildcard_pos'>1 & `wildcard_pos'<`string_len' {
				local c1 = substr("`c'",1,`wildcard_pos'-1) + "*" + substr("`c'",`wildcard_pos'+1,.)
				local c2 = substr("`c'",1,`wildcard_pos'-1) + substr("`c'",`wildcard_pos'+1,.) + "*"
				local c3 = substr("`c'",1,`wildcard_pos'-1) + substr("`c'",`wildcard_pos'+1,.)
				rename `c2' `c1'
			}
			* When @ symbol is at the end of the string
			if `wildcard_pos'==`string_len' {
				local c3 = substr("`c'",1,`wildcard_pos'-1)
			}
			* When @ symbol is at the beginning of the string
			if `wildcard_pos'==1 {
				local c1 = "*" + substr("`c'",`wildcard_pos'+1,.)
				local c2 = substr("`c'",`wildcard_pos'+1,.) + "*"
				local c3 = substr("`c'",`wildcard_pos'+1,.)
				rename `c2' `c1'
			}
		}
	}
	
	* Format nicely
	if "`verbose'"!="" timer on 5
	local num_obs_wide = `=_N'
	local num_vars_wide = `=c(k)'
	if "`verbose'"!="" timer off 6
	
	* Display output
	if "`verbose'"!="" timer on 6
	di ""
	di as text "Data" _col(28) %12s "long" _col(43) "->" _col(48) "wide"
	di as text "{hline 78}"
	di as text "Number of obs." _col(28) %12s "`num_obs_long'" _col(43) "->" _col(48) "`num_obs_wide'"
	di as text "Number of variables" _col(28) %12s "`num_vars_long'" _col(43) "->" _col(48) "`num_vars_wide'"
	di as text "j variable (`num_j' values)" _col(28) %12s "`j'"  _col(43) "->" _col(48) "(dropped)"
	di as text "xij variables:"
	foreach v in `stub_vars' {
		if `num_j'==3 {
			di as text _col(28) %12s "`v'" _col(43) "->" _col(48) "`v'`j1' `v'`j2' `v'`j3'"
		}
		else if `num_j'==2 {
			di as text _col(28) %12s "`v'" _col(43) "->" _col(48) "`v'`j1' `v'`j2'"
		}
		else if `num_j'==1 {
			di as text _col(28) %12s "`v'" _col(43) "->" _col(48) "`v'`j1'"
		}
		else {
			di as text _col(28) %12s "`v'" _col(43) "->" _col(48) "`v'`j1' `v'`j2' ... `v'`j3'"
		}
	}
	di as text "{hline 78}"
	if "`verbose'"!="" timer off 6

}

*-------------------------------------------------------------------------------
* Long reshape
* Kudos to http://www.nber.org/stata/efficient/reshape.html
*-------------------------------------------------------------------------------

if "`rtype'"=="long" {

	local num_obs_wide = `=_N'
	local num_vars_wide = `=c(k)'
	
	* @ functionality for stubs
	foreach v in `stubs' {
		local c = "`v'"
	    local wildcard_pos = strpos("`c'","@")
		local string_len = strlen("`c'")
		//di "pos: `wildcard_pos', len: `string_len'"
		if `wildcard_pos'>0 {
			* When @ symbol is in the middle of the string
			if `wildcard_pos'>1 & `wildcard_pos'<`string_len' {
				local c1 = substr("`c'",1,`wildcard_pos'-1) + "*" + substr("`c'",`wildcard_pos'+1,.)
				local c2 = substr("`c'",1,`wildcard_pos'-1) + substr("`c'",`wildcard_pos'+1,.) + "*"
				local c3 = substr("`c'",1,`wildcard_pos'-1) + substr("`c'",`wildcard_pos'+1,.)
				rename `c1' `c2'
				local stubs2 `stubs2' `c3'
			}
			* When @ symbol is at the end of the string
			if `wildcard_pos'==`string_len' {
				local c3 = substr("`c'",1,`wildcard_pos'-1)
				local stubs2 `stubs2' `c3'
			}
			* When @ symbol is at the beginning of the string
			if `wildcard_pos'==1 {
				local c1 = "*" + substr("`c'",`wildcard_pos'+1,.)
				local c2 = substr("`c'",`wildcard_pos'+1,.) + "*"
				local c3 = substr("`c'",`wildcard_pos'+1,.)
				rename `c1' `c2'
				local stubs2 `stubs2' `c3'
			}
		}
		else {
			local stubs2 `stubs2' `c'
		}
	}
	local stubs `stubs2'
	//di "debug: stubs = `stubs'"
	
	* Store distinct values of j across all stubs
	if "`verbose'"!="" timer on 1
	foreach v in `stubs' {
		local stub_vars_raw
		capture describe `v'*, varlist
		if "`=r(varlist)'"!="." {
			local stub_vars_raw `stub_vars_raw' `=r(varlist)'
		}
		foreach v2 in `stub_vars_raw' {
			local c = subinstr("`v2'","`v'","",.)
			local stub_vars_clean `stub_vars_clean' `c'
		}
		local all_stubs `all_stubs' `stub_vars_raw'
	} 
	//di "debug: stub_vars_raw = `stub_vars_raw'"
	
	* Store unique values of j variable (non-string)
	if "`string'"=="" {
		mata: st_matrix("unique_j", uniqrows(strtoreal(tokens(st_local("stub_vars_clean")))'))
		local num_j = rowsof(unique_j)
		forval z=1/`num_j' {
			if "`=unique_j[`z',1]'"!="." {
				local list_j `list_j' `=unique_j[`z',1]'
			}
		}
		di as text "(note: j = `list_j')"
	}
	
	* Store unique values of j variable (string)
	if "`string'"!="" {
		mata: unique_j = uniqrows(tokens(st_local("stub_vars_clean")))'
		mata: st_local("num_j",strofreal(rows(unique_j)))
		gen unique_j = ""
		forvalues z=1/`num_j' {
			mata: st_local("curr",unique_j[`z',1])
			local unique_j`z' = "`curr'" in `z'
		}
		forval z=1/10 {
			if `z'<=`num_j' {
				if "`unique_j`z''"!="." {
					local list_j `list_j' `unique_j`z''
				}
			}
		}
		di as text "(note: j = `list_j')"
	}
	if "`verbose'"!="" timer off 1
	
	* Identify all variables in dataset NOT i, j, stub
	if "`verbose'"!="" timer on 2
	if "`string'"=="" qui ds `all_stubs' `i', not
	else qui ds `all_stubs' `i' unique_j, not
	local non_stubs `r(varlist)'
	if "`verbose'"!="" timer off 2
	
	* Write out a separate file for each value of j
	if "`verbose'"!="" timer on 3
	tempfile tmp_long
	qui save `tmp_long'
	forval z=1/`num_j' {
		if "`string'"=="" local c = unique_j[`z',1]
		else local c `unique_j`z''
		local allstubs
		foreach s in `stubs' {
			cap desc `s'`c' using `tmp_long'
			if _rc!=0 {
				di as text "(note: `s'`c' not found)"
				local genlong = 1
			}
			local allstubs `allstubs' `s'`c'
		}
		use `i' `allstubs' `non_stubs' using `tmp_long', clear
		if "`genlong'"=="1" gen `s'`c' = .
		if "`string'"=="" gen `j' = `c'
		else gen `j' = "`c'"
		di "c = `c', s = `s', j = `j'"
		foreach s in `stubs' {
			cap rename `s'`c' `s'
		}
		di "after"
		tempfile temp`z'
		qui save `temp`z'', replace
	}
	if "`verbose'"!="" timer off 3
	
	* Concatenate temp files
	if "`verbose'"!="" timer on 4
	clear
	forval z=1/`num_j' {
		append using `temp`z''
	}
	if "`verbose'"!="" timer off 4
	
	* Format nicely
	if "`verbose'"!="" timer on 5
	order `i' `j', first
	if "`fast'"=="" {
		sort `i' `j'
	}
	local num_obs_long = `=_N'
	local num_vars_long = `=c(k)'
	if "`verbose'"!="" timer off 5
	
	* Display output
	if "`verbose'"!="" timer on 6
	di ""
	di as text "Data" _col(28) %12s "wide" _col(43) "->" _col(48) "long"
	di as text "{hline 78}"
	di as text "Number of obs." _col(28) %12s "`num_obs_wide'" _col(43) "->" _col(48) "`num_obs_long'"
	di as text "Number of variables" _col(28) %12s "`num_vars_wide'" _col(43) "->" _col(48) "`num_vars_long'"
	di as text "j variable (`num_j' values)" _col(43) "->" _col(48) "`j'"
	di as text "xij variables:"
	foreach v in `stubs' {
		if `num_j'==3 {
			if "`string'"=="" {
				local j1 = unique_j[1,1]
				local j2 = unique_j[2,1]
				local j3 = unique_j[3,1]
			}
			else {
				local j1 `unique_j1'
				local j2 `unique_j2'
				local j3 `unique_j3'
			}
			di as text _col(2) %38s "`v'`j1' `v'`j2' `v'`j3'" _col(43) "->" _col(48) "`v'"
		}
		else if `num_j'==2 {
			if "`string'"=="" {
				local j1 = unique_j[1,1]
				local j2 = unique_j[2,1]
			}
			else {
				local j1 `unique_j1'
				local j2 `unique_j2'
			}
			di as text _col(2) %38s "`v'`j1' `v'`j2'" _col(43) "->" _col(48) "`v'"
		}
		else if `num_j'==1 {
			if "`string'"=="" {
				local j1 = unique_j[1,1]
			}
			else {
				local j1 `unique_j1'
			}
			di as text _col(2) %38s "`v'`j1'" _col(43) "->" _col(48) "`v'"
		}
		else {
			if "`string'"=="" {
				local j1 = unique_j[1,1]
				local j2 = unique_j[2,1]
				local j3 = unique_j[`num_j',1]
			}
			else {
				local j1 `unique_j1'
				local j2 `unique_j2'
				local j3 `unique_j`num_j''
			}
			di as text _col(2) %38s "`v'`j1' `v'`j2' ... `v'`j3'" _col(43) "->" _col(48) "`v'"
		}
	}
	di as text "{hline 78}"
	if "`verbose'"!="" timer off 6
}

*-------------------------------------------------------------------------------
* XX optional: return objects
*-------------------------------------------------------------------------------

char _dta[ReS_rtype]     `rtype'
char _dta[ReS_stubs]     `stubs'
char _dta[ReS_i]         `i'
char _dta[ReS_j]         `j'     
/*
char _dta[ReS_jv]        j values, if specified
char _dta[ReS_Xij]  
char _dta[ReS_Xij_n]     number of X_ij variables
char _dta[ReS_Xij_long#] name of #th X_ij variable in long form
char _dta[ReS_Xij_wide#] name of #th X_ij variable in wide form
char _dta[ReS_Xi]        X_i variable names, if specified
char _dta[ReS_atwl]      atwl() value, if specified
char _dta[ReS_str]       1 if option string specified; 0 otherwise
*/

if "`verbose'"!="" {
	qui timer list
	di "Time for stub formatting: `r(t1)'"
	di "Time for identifying non-stub, i, j vars: `r(t2)'"
	di "Time for writing out files for each j: `r(t3)'"
	di "Time for concatenating files: `r(t4)'"
	di "Time for formatting: `r(t5)'"
	di "Time for printing output: `r(t6)'"
	timer clear
}

*-------------------------------------------------------------------------------
* End
*-------------------------------------------------------------------------------

cap restore, not

end
