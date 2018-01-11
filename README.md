
#fastreshape

[Overview](#overview)
| [Installation](#installation)
| [Usage](#usage)
| [FAQs](#faqs]
| [Benchmarks](#remarks)
| [Acknowledgements](#acknowledgements)
| [Remarks](#remarks)
| [License](#license)

More efficient implementation of reshape in Stata

`version 0.1 20180111

Overview
---------------------------------

fastreshape is an enhanced version of the built-in reshape program in Stata.

1. Better performance: This program runs two to five times faster than reshape in most use cases.
2. New features: Binscatter2 allows users to nonparametrically represent the distribution of y given x rather than simply the mean. 



Installation
------------

There are three options for installing fastreshape. 

- The most recent iteration can always be downloaded from this Github page. 
The following block of Stata code will install the most recent version 
or check for updates relative to your existing installation:

```stata
local github "https://raw.githubusercontent.com"
net install gtools, from(`github'/mdroste/stata-fastreshape/master/build/)
* adoupdate, update
* ado uninstall gtools
```

- This program is also available on SSC.
```stata
ssc install fastreshape
```

- If your computer or server does not have access to the internet to run the commands
above, you can download the .ado from here or the IDEAS archive (here) and place on your
adopath directly.


Usage
------------

The syntax for usage is exactly the same as reshape. Internal documentation (a help file)
can be accessed within Stata:
```stata
help fastreshape

Remarks
-------



Acknowledgements
----------------

* This program owes its existence to the discussion provided by Robert Picard, Daniel Feenberg and Paul Von Hippel at Statalist.

  
Todo
----

Roadmap to 1.0

- Option when the initial dataset is a balanced panel 


License
-------

fastreshape is [MIT-licensed](https://github.com/mcaceresb/stata-gtools/blob/master/LICENSE).

