
fastreshape.ado 
===================================

[Overview](#overview)
| [Installation](#installation)
| [Usage](#usage)
| [Benchmarks](#remarks)
| [To-Do](#todo)
| [Acknowledgements](#acknowledgements)
| [License](#license)

More efficient implementation of reshape in Stata

`version 0.1 2018jan11`

Overview
---------------------------------

fastreshape is an enhanced version of the built-in reshape program in Stata. 

This program runs two to five times faster than reshape in most use cases.


Installation
---------------------------------

There are two options for installing fastreshape. The program is not yet available on SSC.

1. The most recent version can be downloaded directly from Github.

Stata code:
```stata
local github "https://raw.githubusercontent.com"
net install fastreshape, from(`github'/mdroste/stata-fastreshape/master/build/)
```

2. A ZIP containing the program can be downloaded and manually placed on the user's adopath.


Usage
---------------------------------

The syntax for usage is exactly the same as reshape. 

Internal documentation (a help file) can be accessed within Stata:
```stata
help fastreshape
```

Benchmarks
---------------------------------

Reshape wide benchmarks:

| # i vals  | # j vals = 10  | # j vals = 100 | # j vals = 1k  |
| --------- | -------------- | -------------- | -------------- |
| 1k        | xx  		     | xx  		      | xx  		   |
| 10k       | xx  		     | xx  		  	  | xx  		   |
| 100k      | xx  		     | xx     		  | xx  		   |
| 1m        | xx  		     | xx             | xx  		   |
| 10m       | xx  		     | xx      	  	  | xx  		   |
| 100m 		| xx  		     | xx  		      | xx  		   |

Reshape long benchmarks:

| # i vals  | # j vals = 10  | # j vals = 100 | # j vals = 1k  |
| --------- | -------------- | -------------- | -------------- |
| 1k        | xx  		     | xx  		      | xx  		   |
| 10k       | xx  		     | xx  		  	  | xx  		   |
| 100k      | xx  		     | xx     		  | xx  		   |
| 1m        | xx  		     | xx             | xx  		   |
| 10m       | xx  		     | xx      	  	  | xx  		   |
| 100m 		| xx  		     | xx  		      | xx  		   |


Acknowledgements
---------------------------------

This program was inspired by [this discussion](https://www.statalist.org/forums/forum/general-stata-discussion/general/1338350-making-reshape-faster/) provided by Robert Picard, Daniel Feenberg and Paul Von Hippel on Statalist.

  
Todo
---------------------------------

I would like to get around to addressing the following items:

- Option when the initial dataset is a balanced panel 


License
---------------------------------

fastreshape is [MIT-licensed](https://github.com/mdroste/stata-fastreshape/blob/master/LICENSE).

