
fastreshape
=======================

[Overview](#overview)
| [Installation](#installation)
| [Usage](#usage)
| [Benchmarks](#benchmarks)
| [To-Do](#todo)
| [Acknowledgements](#acknowledgements)
| [License](#license)

More efficient implementation of reshape in Stata

`version 0.1 2018jan11`

Overview
---------------------------------

fastreshape is an enhanced version of the built-in reshape program in Stata. 

This program runs 1.5 to 5 times faster than reshape in most use cases, particularly when the number of i values is large relative to the number of j values.


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

The syntax, usage, and data output is mostly identical to reshape, with a few exceptions:

1. By default, fastreshape does not return additional output in macros. Support for this functionality is not yet included (see to-do).
2. Fastreshape does not allow you to diagnose 'problem observations' with the -fastreshape error' command ex post. Support for this functionality may be included at a later date, but is not viewed as particularly important at this time.

Internal documentation for fastreshape can be accessed within Stata:
```stata
help fastreshape
```

More helpful usage notes on the reshaping procedure can be found in the official Stata documentation for reshape:
```stata
help reshape
```

Benchmarks
---------------------------------

Reshape wide benchmarks:

| # i vals  | # j vals = 10  | # j vals = 50 | # j vals = 100  |
| --------- | -------------- | -------------- | -------------- |
| 1k        | 2.5  		     | 1.4 		  	  | 1.3  		   |
| 10k       | 2.6  		     | 1.6 		  	  | 1.5  		   |
| 100k      | 3.5  		     | 1.8     		  | xx  		   |
| 1m        | 5.9  		     | xx             | xx  		   |

Reshape long benchmarks:

| # i vals  | # j vals = 10  | # j vals = 50  | # j vals = 100 |
| --------- | -------------- | -------------- | -------------- |
| 1k        | 1.2  		     | 1.5 		  	  | 1.4  		   |
| 10k       | 2.0  		     | 2.1 		      | 3.9  		   |
| 100k      | 2.1  		     | 3.9     		  | xx  		   |
| 1m        | 2.6  		     | xx             | xx  		   |

  
Todo
---------------------------------

I would like to address the following items:

- [ ] Option to return additional information in scalars with optional [return] argument.
- [ ] Option to leverage [gtools](https://github.com/mcaceresb/stata-gtools/)
- [ ] Option when initial dataset structure is known (e.g. balanced panel)
- [ ] More informative dialogue 

A port of this program in C would yield a significant increase in performance; I have no plans to do that in the near future.


Acknowledgements
---------------------------------

This program was inspired by [this discussion](https://www.statalist.org/forums/forum/general-stata-discussion/general/1338350-making-reshape-faster/) provided by Robert Picard, Daniel Feenberg and Paul Von Hippel on Statalist.


License
---------------------------------

fastreshape is [MIT-licensed](https://github.com/mcaceresb/stata-gtools/blob/master/LICENSE).

