
fastreshape.ado 

[Overview](#overview)
| [Installation](#installation)
| [Usage](#usage)
| [FAQs](#faqs)
| [Benchmarks](#remarks)
| [Acknowledgements](#acknowledgements)
| [Remarks](#remarks)
| [License](#license)

More efficient implementation of reshape in Stata

`version 0.1 2018jan11`

Overview
---------------------------------

fastreshape is an enhanced version of the built-in reshape program in Stata. 
This program runs two to five times faster than reshape in most use cases.


Installation
------------

There are three options for installing fastreshape. 

1. The most recent iteration can always be downloaded from this Github page. 
The following Stata code willinstall the most recent version directly from Github:

```stata
local github "https://raw.githubusercontent.com"
net install gtools, from(`github'/mdroste/stata-fastreshape/master/build/)
* adoupdate, update
* ado uninstall gtools
```

2. This program is also available on SSC.
```stata
ssc install fastreshape
```

3. If your computer or server does not have access to the internet to run the commands
above, you can download the .ado from here or the IDEAS archive (here) and place on your
adopath directly.


Usage
------------

The syntax for usage is exactly the same as reshape. 

Internal documentation (a help file) can be accessed within Stata:
```stata
help fastreshape
```

Remarks
-------



Acknowledgements
----------------

This program was inspired by [this discussion](https://www.statalist.org/forums/forum/general-stata-discussion/general/1338350-making-reshape-faster/) provided by Robert Picard, Daniel Feenberg and Paul Von Hippel on Statalist.

  
Todo
----

Roadmap to 1.0

- Option when the initial dataset is a balanced panel 


License
-------

fastreshape is [MIT-licensed](https://github.com/mcaceresb/stata-gtools/blob/master/LICENSE).

