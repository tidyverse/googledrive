
<!-- README.md is generated from README.Rmd. Please edit that file -->
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
-   Functions and parameters attempt to mimic convetions for working with local files in R, such as `list.files()`.
-   The metadata for one or more Drive files is held in a `dribble`, a data frame with one row per file. A dribble is returned (and accepted) by almost every function in googledrive.

### Quick demo

Here's how to list the most recently modified 100 files on your drive. This will kick off your authentication, so you will be sent to your browser to authorize your Google Drive access. The functions here are designed to be pipeable, using `%>%`, however they obviously don't require it.

``` r
drive_search()
#> # A tibble: 132 x 3
#>                           name
#>  *                       <chr>
#>  1                         def
#>  2                         abc
#>  3                      foobar
#>  4                    chickwts
#>  5                chickwts.rda
#>  6          chicken_little.jpg
#>  7               chicken_small
#>  8                      filler
#>  9 chickwts-TEST-drive-publish
#> 10          another-share-test
#> # ... with 122 more rows, and 2 more variables: id <chr>,
#> #   files_resource <list>
```

You can narrow the query by specifying a `pattern` you'd like to match names against.

``` r
drive_search(pattern = "baz")
```

Alternatively, you can refine the search using the `q` query parameter. Accepted search clauses can be found in the [Google Drive API documentation](https://developers.google.com/drive/v3/web/search-parameters). For example, if I wanted to search for all spreadsheets, I could run the following.

``` r
(sheets <- drive_search(q = "mimeType = 'application/vnd.google-apps.spreadsheet'"))
#> # A tibble: 1 x 3
#>                   name                                           id
#> *                <chr>                                        <chr>
#> 1 538-star-wars-survey 1xw_M2OBUdPjoOVrmWKWNu07BW_PHCh-EMSfJN5WEJDE
#> # ... with 1 more variables: files_resource <list>
class(sheets)
#> [1] "dribble"    "tbl_df"     "tbl"        "data.frame"
```

You often want to store the result of a googledrive call, so you can act on those files in the future.

#### Identify files

In addition to `drive_search()`, you can also identify files by name (path, really) or Drive file id, using `drive_path()` and `drive_get()`, respectively. You can also register a Google Drive id as a `drive_id` or convert a Google Drive URL to a `drive_id` using `as_id()`. These `drive_id` objects can be passed to any of our functions.

``` r
(x <- drive_path("~/abc/def"))
#> # A tibble: 1 x 3
#>    name                           id files_resource
#> * <chr>                        <chr>         <list>
#> 1   def 0B0Gh-SuuA2nTSHNoNDJqRmJobWc    <list [30]>
## let's grab that file id and retrieve it that way
x$id
#> [1] "0B0Gh-SuuA2nTSHNoNDJqRmJobWc"

drive_get(x$id)
#> # A tibble: 1 x 3
#>    name                           id files_resource
#> * <chr>                        <chr>         <list>
#> 1   def 0B0Gh-SuuA2nTSHNoNDJqRmJobWc    <list [30]>
```

In general, googledrive functions let you specify Drive file(s) by name (path), file id, and `dribble`. See examples below.

#### Upload files

We can upload any file type.

``` r
write.csv(chickwts, "README-chickwts.csv")
(drive_chickwts <- drive_upload("README-chickwts.csv"))
#> File uploaded to Google Drive:
#> README-chickwts.csv
#> with MIME type:
#> text/csv
#> # A tibble: 1 x 3
#>                  name                           id files_resource
#> *               <chr>                        <chr>         <list>
#> 1 README-chickwts.csv 0B0Gh-SuuA2nTWGlUdXBBcEhQSm8    <list [36]>
```

Notice that file was uploaded as `text/csv`. Since this was a `.csv` document, and we didn't specify the type, googledrive assumed it was to be uploaded as such (`?drive_upload` for a full list of assumptions). We can overrule this by using the `type` parameter to have it load as a Google Spreadsheet. Let's delete this file first.

``` r
## example of using a dribble as input
drive_chickwts <- drive_chickwts %>%
  drive_delete()
#> Files deleted:
#>   * README-chickwts.csv: 0B0Gh-SuuA2nTWGlUdXBBcEhQSm8
```

``` r
drive_chickwts <- drive_upload("README-chickwts.csv", type = "spreadsheet")
#> File uploaded to Google Drive:
#> README-chickwts.csv
#> with MIME type:
#> application/vnd.google-apps.spreadsheet
```

Much better!

#### Publish files

Versions of Google Documents, Sheets, and Presentations can be published online. By default, `drive_publish()` will publish your most recent version. You can check your publication status by running `drive_check_publish()`.

``` r
drive_is_published(drive_chickwts)
#> The latest revision of the Google Drive file 'README-chickwts.csv' is not published.
```

``` r
drive_chickwts <- drive_publish(drive_chickwts)
#> You have changed the publication status of 'README-chickwts.csv'.
drive_chickwts$publish
#> # A tibble: 1 x 4
#>            check_time revision published auto_publish
#>                <dttm>    <chr>     <lgl>        <lgl>
#> 1 2017-06-26 17:30:21        1      TRUE         TRUE
```

``` r
drive_is_published(drive_chickwts)
#> The latest revision of Google Drive file 'README-chickwts.csv' is published.
```

#### Share files

Notice the access here says "Shared with specific people". To update the access, we need to change the sharing permissions. Let's say I want anyone with the link to be able to view my dataset.

``` r
drive_chickwts <- drive_chickwts %>%
  drive_share(role = "reader", type = "anyone")
#> The permissions for file 'README-chickwts.csv' have been updated.
#> id: anyoneWithLink
#> type: anyone
#> role: reader
```

We always assign the return value of googledrive functions back into an R object. This object is of type `dribble`, which holds metadata on one or more Drive files. By constantly re-assigning the value, we keep it current, facilitating all downstream operations.

We can then extract a share link.

``` r
drive_chickwts %>%
  drive_share_link()
#> [1] "https://docs.google.com/spreadsheets/d/18On30CltNkW2b_wWu9GPE7CI0GCfH6SAn7LB0dUyoeA/edit?usp=drivesdk"
```

#### Download files

##### Google files

We can download files from Google Drive. Google type files (such as Google Documents, Google Sheets, Google Slides, etc.) need to have the file local file extension specified either with the `type` or `out_path` parameters. For example, if I would like to download the "538-star-wars-survey" Google Sheet as a `.csv` I could run the following.

``` r
drive_download("538-star-wars-survey", type = "csv")
#> File downloaded from Google Drive:
#> '538-star-wars-survey'
#> Saved locally as:
#> '538-star-wars-survey.csv'
```

Alternatively, I could specify the `out_path` parameter.

``` r
drive_download("538-star-wars-survey",
               out_path = "538-star-wars-survey.csv",
               overwrite = TRUE)
#> File downloaded from Google Drive:
#> '538-star-wars-survey'
#> Saved locally as:
#> '538-star-wars-survey.csv'
```

Notice in the example above, I specified `overwrite = TRUE`. This allowed me to overwrite the file previously saved.

##### All other files

Downloading files that are *not* Google type files (for example a file uploaded as a `.csv`, `.rda`, or `.txt`) does not require the extension specification. You can still specify the desired local file name and location using `out_path` or allow the function to default to the file name on Google Drive and save to your working directory. For example, I can download the `drive_chickwts` csv we just uploaded in the following manner.

``` r
drive_download(drive_chickwts, overwrite = TRUE)
#> File downloaded from Google Drive:
#> 'README-chickwts.csv'
#> Saved locally as:
#> 'README-chickwts.csv'
```

#### Clean up

``` r
drive_chickwts %>%
  drive_delete()
#> Files deleted:
#>   * README-chickwts.csv: 18On30CltNkW2b_wWu9GPE7CI0GCfH6SAn7LB0dUyoeA
```
