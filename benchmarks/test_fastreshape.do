
*===============================================================================
* FILE:    test_fastreshape.ado
* PURPOSE: Test out fastreshape on a few datasets
*===============================================================================

*-------------------------------------------------------------------------------
* Setup
*-------------------------------------------------------------------------------

* Install latest version of fastreshape
cap program drop fastreshape
net install fastreshape, from("https://raw.githubusercontent.com/mdroste/stata-fastreshape/master/")

*-------------------------------------------------------------------------------
* Test 1: wide to long
*-------------------------------------------------------------------------------

webuse reshape1, clear
fastreshape long inc ue, i(id) j(year)
tempfile t1a
save `t1a'

webuse reshape1, clear
reshape long inc ue, i(id) j(year)
tempfile t1b
save `t1b'

* Compare fastreshape and reshape output
use `t1a', clear
cf _all using `t1b'

*-------------------------------------------------------------------------------
* Test 2: wide to long, string
*-------------------------------------------------------------------------------

* Test fastreshape
webuse reshape4, clear
fastreshape long inc, i(id) j(sex) string
tempfile t2a
save `t2a'

* Test reshape
webuse reshape4, clear
reshape long inc, i(id) j(sex) string
tempfile t2b
save `t2b'

* Compare fastreshape and reshape output
use `t2a', clear
cf _all using `t2b'

*-------------------------------------------------------------------------------
* Test 3: wide to long and then long to wide, string
*-------------------------------------------------------------------------------

* Test fastreshape
webuse reshape4, clear
fastreshape long inc, i(id) j(sex) string
fastreshape wide inc, i(id) j(sex) string
tempfile t3a
save `t3a'

* Test reshape
webuse reshape4, clear
reshape long inc, i(id) j(sex) string
reshape wide inc, i(id) j(sex) string
tempfile t3b
save `t3b'

* Compare fastreshape and reshape output
use `t3a', clear
cf _all using `t3b'

*-------------------------------------------------------------------------------
* Test 4: long to wide twice, string, @
*-------------------------------------------------------------------------------

* Test fastreshape
webuse reshape5, clear
fastreshape wide @inc, i(hid year) j(sex) string
fastreshape wide minc finc, i(hid) j(year)
tempfile t4a
save `t4a'

* Test reshape
webuse reshape5, clear
reshape wide @inc, i(hid year) j(sex) string
reshape wide minc finc, i(hid) j(year)
tempfile t4b
save `t4b'

* Compare fastreshape and reshape output
use `t4a', clear
cf _all using `t4b'

*-------------------------------------------------------------------------------
* Test 5: long to wide
*-------------------------------------------------------------------------------

* Generate (long) data
clear all
set obs 10000
gen i = _n
expand 10
bysort i: gen j = _n
gen x = runiform()
tempfile t5
save `t5'

* Test fastreshape
use `t5', clear
fastreshape wide x, i(i) j(j)
tempfile t5a
save `t5a'

* Test reshape
use `t5', clear
reshape wide x, i(i) j(j)
tempfile t5b
save `t5b'

* Compare fastreshape and reshape output
use `t5a', clear
cf _all using `t5b'

*-------------------------------------------------------------------------------
* Test 6: wide to long
*-------------------------------------------------------------------------------

* Generate (wide) data
clear all
set obs 100000
gen i = _n
forval i=1/10 {
	gen x`i' = runiform()
}
tempfile t6
save `t6'

* Test fastreshape
use `t6', clear
fastreshape long x, i(i) j(j)
tempfile t6a
save `t6a'

* Test reshape
use `t6', clear
reshape long x, i(i) j(j)
tempfile t6b
save `t6b'

* Compare fastreshape and reshape output
use `t6a', clear
cf _all using `t6b'

*-------------------------------------------------------------------------------
* Test 7: long to wide, w/ missing data
*-------------------------------------------------------------------------------

* Generate (long) data
clear all
set obs 10000
gen i = _n
expand 10
bysort i: gen j = _n
gen x = runiform()
replace x = . if j==7
tempfile t7
save `t7'

* Test fastreshape
use `t7', clear
fastreshape wide x, i(i) j(j)
tempfile t7a
save `t7a'

* Test reshape
use `t7', clear
reshape wide x, i(i) j(j)
tempfile t7b
save `t7b'

* Compare fastreshape and reshape output
use `t7a', clear
cf _all using `t7b'

*-------------------------------------------------------------------------------
* Test 8: wide to long, w/ missing data
*-------------------------------------------------------------------------------

* Generate (wide) data
clear all
set obs 100000
gen i = _n
forval i=1/10 {
	gen x`i' = runiform()
}
replace x7 = .
tempfile t8
save `t8'

* Test fastreshape
use `t8', clear
fastreshape long x, i(i) j(j)
tempfile t8a
save `t8a'

* Test reshape
use `t8', clear
reshape long x, i(i) j(j)
tempfile t8b
save `t8b'

* Compare fastreshape and reshape output
use `t8a', clear
cf _all using `t8b'