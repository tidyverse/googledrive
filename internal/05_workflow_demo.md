workflow demo
================
Lucy D’Agostino McGowan
5/8/2017

-   [get file](#get-file)
-   [publish file](#publish-file)
-   [check publication status](#check-publication-status)
-   [edit file in browser](#edit-file-in-browser)

I'm demoing a simple workflow, using our to-do list as an example

``` r
library(googledrive)
library(dplyr)
```

get file
--------

``` r
our_file <- gd_get_id("Lucy & Jenny") %>% 
  gd_file
```

publish file
------------

``` r
our_file <- our_file %>%
  gd_publish
```

    ## You have changed the publication status of '🌻 Lucy & Jenny'.

check publication status
------------------------

``` r
our_file$publish
```

    ## # A tibble: 1 × 5
    ##            check_time revision published auto_publish       last_user
    ##                <dttm>    <chr>     <lgl>        <lgl>           <chr>
    ## 1 2017-05-09 17:12:28      742      TRUE         TRUE Lucy D'Agostino

edit file in browser
--------------------

``` r
gd_open(our_file)
```
