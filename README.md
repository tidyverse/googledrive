
<!-- README.md is generated from README.Rmd. Please edit that file -->
    ## Auto-refreshing stale OAuth token.

googledrive
===========

[![Build Status](https://travis-ci.org/tidyverse/googledrive.svg?branch=master)](https://travis-ci.org/tidyverse/googledrive)[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/tidyverse/googledrive?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/googledrive)[![Coverage Status](https://img.shields.io/codecov/c/github/tidyverse/googledrive/master.svg)](https://codecov.io/github/tidyverse/googledrive?branch=master)

WARNING: this is very much under construction

Overview
--------

`googledrive` interfaces with Google Drive from R, allowing users to seamlessly manage files on Google Drive from the comfort of their console.

Installation
------------

``` r
# Obtain the the development version from GitHub:
# install.packages("devtools")
devtools::install_github("tidyverse/googledrive")
```

Usage
-----

### Load `googledrive`

``` r
library("googledrive")
```

### Package conventions

-   All functions begin with the prefix `drive_`
-   Functions and parameters attempt to mimic local file navigating conventions in R, such as `list.files`.

### Quick demo

Here's how to list the most recently modified 100 files on your drive. This will kick off your authentication, so you will be sent to your browser to authorize your Google Drive access. The functions here are designed to be pipeable, using `%>%`, however they can also be implemented without.

``` r
drive_list()
#> # A tibble: 100 x 5
#>                         name       type    parents
#>                        <chr>      <chr>     <list>
#>  1                  chickwts   document <list [1]>
#>  2                  chickwts   document <list [1]>
#>  3                  chickwts   document <list [1]>
#>  4                  chickwts   document <list [1]>
#>  5                  chickwts   document <list [1]>
#>  6                  chickwts   document <list [1]>
#>  7                  chickwts   document <list [1]>
#>  8                  chickwts   document <list [1]>
#>  9 chickwts_382878401782.txt text/plain <list [1]>
#> 10 chickwts_160767344525.txt   document <list [1]>
#> # ... with 90 more rows, and 2 more variables: id <chr>, gfile <list>
```

You can narrow the query by specifying a `path` and/or `pattern` you'd like to search within. For example, to search within the folder `foobar` for a file named `baz` you could run either of the following.

``` r
drive_list(path = "foobar", pattern = "baz")
drive_list(path = "foobar/baz")
```

Alternatively, you can refine the search using the `q` query parameter. Accepted search clauses can be found in the [Google Drive API documentation](https://developers.google.com/drive/v3/web/search-parameters). For example, if I wanted to search for all spreadsheets, I could run the following.

``` r
drive_list(q = "mimeType = 'application/vnd.google-apps.spreadsheet'")
#> # A tibble: 1 x 5
#>                   name        type    parents
#>                  <chr>       <chr>     <list>
#> 1 538-star-wars-survey spreadsheet <list [1]>
#> # ... with 2 more variables: id <chr>, gfile <list>
```

#### Upload files

We can upload any file type.

``` r
write.table(chickwts, "chickwts.txt")
drive_chickwts <- drive_upload("chickwts.txt")
#> File uploaded to Google Drive: 
#> chickwts.txt 
#> As the Google document named:
#> chickwts
```

We now have a file of class `gfile` that contains information about the uploaded file.

``` r
drive_chickwts
#> File name: chickwts 
#> File owner: tidyverse testdrive 
#> File type: document 
#> Last modified: 2017-05-21 
#> Access: Shared with specific people.
```

Notice that file was uploaded as a `document`. Since this was a `.txt` document, and we didn't specify the type, `googledrive` assumed it was a document (`?drive_upload` for a full list of assumptions). We can overrule this by using the `type` parameter. Let's delete this file first.

``` r
drive_chickwts <- drive_chickwts %>%
  drive_delete()
#> The file 'chickwts' has been deleted from your Google Drive
```

``` r
drive_chickwts <- drive_upload("chickwts.txt", type = "spreadsheet")
#> File uploaded to Google Drive: 
#> chickwts.txt 
#> As the Google spreadsheet named:
#> chickwts
```

Let's see if that worked.

``` r
drive_chickwts
#> File name: chickwts 
#> File owner: tidyverse testdrive 
#> File type: spreadsheet 
#> Last modified: 2017-05-21 
#> Access: Shared with specific people.
```

Much better!

#### Share files

Notice the access here says "Shared with specific people". To update the access, we need to change the sharing permissions. Let's say I want anyone with the link to be able to view my dataset.

``` r
drive_chickwts <- drive_chickwts %>%
  drive_share(role = "reader", type = "anyone")
#> The permissions for file 'chickwts' have been updated
```

We always assign the return value of googledrive functions back into an R object. This object is of type `gfile`, which holds up-to-date metadata on the associated Drive file. By constantly re-assigning the value, we keep it current, facilitating all downstream operations.

We can then extract a share link.

``` r
drive_chickwts %>%
  drive_share_link()
#> [1] "https://docs.google.com/spreadsheets/d/1juSDnxIcLYa_mzacbmd-wWYiKzOBenwvfTuyVCF2HcA/edit?usp=drivesdk"
```

#### Clean up

``` r
drive_chickwts %>%
  drive_delete()
#> The file 'chickwts' has been deleted from your Google Drive
```
