
fastreshape
=================================

[Overview](#overview)
| [Installation](#installation)
| [Usage](#usage)
| [Benchmarks](#benchmarks)
| [To-Do](#todo)
| [Acknowledgements](#acknowledgements)
| [License](#license)

Faster reshapes in Stata

`version 0.4 24jan2021`


Overview
---------------------------------

fastreshape is a more efficient implementation of the reshape procedure in Stata. 

Although the built-in reshape procedure in Stata is invaluable for working with panel data, it is known to perform poorly on large datasets (see [this benchmark](https://github.com/matthieugomez/benchmark-stata-r) 
and [this discussion](https://www.statalist.org/forums/forum/general-stata-discussion/general/1338350-making-reshape-faster/)).

fastreshape runs several times faster than reshape in most use cases. As described in the [benchmarks](#benchmarks) section below, wide-to-long reshapes are between 2 and 15 times faster with fastreshape, with the largest improvements when the dataset is big.  Similarly, long-to-wide reshapes are between 1.5 and 5 times faster with fastreshape, particularly when the number of logical observations (indexed by i) is large relative to the number of sub-observations (indexed by j).

Usage and output of fastreshape are nearly identical to reshape. See the usage section below.

Installation
---------------------------------

There are three options for installing fastreshape.

1. The most recent version can be installed from Github with the following Stata commands:

```stata
net install fastreshape, from("https://raw.githubusercontent.com/mdroste/stata-fastreshape/master/")
```

2. A recent version can be installed from the SSC repository with the following Stata command:
```stata
ssc install fastreshape
```

3. A ZIP containing the program can be downloaded and manually placed on your adopath.


Usage
---------------------------------

The syntax, usage, and data output of fastreshape is virtually identical to reshape, with a few exceptions:

1. Fastreshape does not support subsetting the sub-observation variables (j) with a list of values (e.g. specifying j(year 2001 2003 2004)).
2. Fastreshape does not support highlighting problem observations with the fastreshape error command ex-post
3. Fastreshape does not support the atwl(char) argument. Use the @ character instead.

Internal documentation for fastreshape is available within Stata after installation:
```stata
help fastreshape
```

More detailed usage notes on the reshaping procedure can be found in the Stata documentation for reshape:
```stata
help reshape
```

Benchmarks
---------------------------------

![fastreshape benchmark](benchmarks/fastreshape_benchmark.png "fastreshape benchmark")


  
Todo
---------------------------------

The following items will be addressed soon:

- [x] Return additional information in scalars with optional argument.
- [x] Support for implicit reshape syntax for repeated reshapes.
- [ ] Return more informative errors.
- [ ] Support for the atwl(char) argument.

A port of this program in C would yield a significant increase in performance; I have no plans to do that in the near future.


Acknowledgements
---------------------------------

This program was inspired by [this Statalist discussion](https://www.statalist.org/forums/forum/general-stata-discussion/general/1338350-making-reshape-faster/) provided by Robert Picard, Daniel Feenberg, and Paul Von Hippel.


License
---------------------------------

fastreshape is [MIT-licensed](https://github.com/mdroste/stata-fastreshape/blob/master/LICENSE).

