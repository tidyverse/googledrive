workflow demo
================
Lucy D’Agostino McGowan
5/8/2017

-   [get file](#get-file)
-   [publish file](#publish-file)
-   [check publication status](#check-publication-status)
-   [edit file in browser](#edit-file-in-browser)
-   [pull in file again](#pull-in-file-again)

I'm demoing a simple workflow, using our to-do list as an example

``` r
library(googledrive)
library(dplyr)
```

get file
--------

``` r
our_file <- drive_get_id("Lucy & Jenny") %>% 
  drive_file
```

publish file
------------

``` r
our_file <- our_file %>%
  drive_publish
```

    ## You have changed the publication status of '🌻 Lucy & Jenny'.

check publication status
------------------------

``` r
our_file$publish
```

    ## # A tibble: 1 × 4
    ##            check_time revision published auto_publish
    ##                <dttm>    <chr>     <lgl>        <lgl>
    ## 1 2017-05-11 10:52:36      777      TRUE         TRUE

edit file in browser
--------------------

``` r
drive_browse(our_file)
```

pull in file again
------------------

``` r
our_file <- drive_get_id("Lucy & Jenny") %>% 
  drive_file
```

``` r
our_file
```

    ## File name: 🌻 Lucy & Jenny 
    ## File owner: Lucy D'Agostino 
    ## File type: document 
    ## Last modified: 2017-05-10 
    ## Access: Anyone who has the link can access. No sign-in required.
