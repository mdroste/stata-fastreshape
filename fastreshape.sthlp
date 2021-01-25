{smcl}
{* *! version 0.4  24jan2021}{...}
{vieweralsosee "fastreshape" "help fastreshape"}{...}
{viewerjumpto "Syntax" "fastreshape##syntax"}{...}
{viewerjumpto "Description" "fastreshape##description"}{...}
{viewerjumpto "Options" "fastreshape##options"}{...}
{viewerjumpto "Examples" "fastreshape##examples"}{...}
{title:Title}

{pstd}
{hi:fastreshape} {hline 2} Efficient implementation of reshape for big datasets


{marker syntax}{title:Syntax}

            long                              wide
        +------------+                 +----------------+
        | i  j  stub |   fastreshape   | i  stub1 stub2 |
        |------------|   <--------->   |----------------|
        | 1  1   4.1 |                 | 1    4.1   4.5 |
        | 1  2   4.5 |                 | 2    3.3   3.0 |
        | 2  1   3.3 |                 +----------------+
        | 2  2   3.0 |         
        +------------+


  To go from long to wide:

{p 8 15 2}
{cmd:fastreshape} wide {it: stub}, i(i) j(j)


  To go from wide to long:

{p 8 15 2}
{cmd:fastreshape} long {it: stub}, i(i) j(j)



{synoptset 20 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt :{cmdab:i(varlist)}}use varlist as the ID variables {p_end}
{synopt :{cmdab:j(varname)}}long->wide: varname, existing variable {p_end}
{synopt :{cmdab:          }}wide->long: varname, new variable {p_end}
{synopt :{cmdab:s:tring   }}j(varname) is a string variable (default numeric){p_end}

{syntab :Advanced}
{synopt :{opt fast}}Speed up processing significantly by not sorting reshaped dataset{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:fastreshape} is an efficient implementation of reshape suitable for large datasets. It converts panel data from wide to long form and vice versa.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}{opt i(varlist)} specifies the variables whose unique values denote a logical observation. i() is required unless using the implicit syntax (see example 2) after having already reshaped once on a given dataset.
 
{phang}{opt j(varname)} specifies the variable whose unique values denote a subobservation.  

{phang}{opt string} specifies that j() may contain string values.


{dlgtab:Advanced}

{phang}{opt fast} speeds up the processing of reshape significantly by not sorting the dataset post-reshape. By default, fastreshape will not use this option and will sort by i and j (for fastreshape long) or by i (for fastreshape wide). This sort order ensures the output of fastreshape matches that of reshape; however, it is time-consuming to enforce this sort order and unncessary for many data tasks.


{marker examples}{...}
{title:Examples}

{marker example1}{...}
{pstd}{bf:Example 1}

{pstd}Load example dataset 1.{p_end}
{phang2}. {stata webuse reshape1, clear}{p_end}

{pstd}Examine the dataset prior to reshaping.{p_end}
{phang2}. {stata list}{p_end}

{pstd}Reshape the data from wide-form to long-form.{p_end}
{phang2}. {stata fastreshape long inc ue, i(id) j(year)}{p_end}

{pstd}Examine the data after reshaping.{p_end}
{phang2}. {stata list}{p_end}

