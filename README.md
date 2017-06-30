
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

-   Almost all functions begin with the prefix `drive_`
-   Functions and parameters attempt to mimic convetions for working with local files in R, such as `list.files()`.
-   The metadata for one or more Drive files is held in a `dribble`, a data frame with one row per file. A dribble is returned (and accepted) by almost every function in googledrive.
-   googledrive is "pipe-friendly" and, in fact, re-exports `%>%`, but does not require its use.

### Quick demo

Here's how to list the files you see in [My Drive](https://drive.google.com). You can expect to be sent to your browser here, to authenticate yourself and authorize the googledrive package to deal on your behalf with Google Drive.

``` r
drive_search()
#> # A tibble: 152 x 3
#>                            name
#>  *                        <chr>
#>  1                          def
#>  2                          abc
#>  3            bar-TEST-drive-mv
#>  4            baz-TEST-drive-mv
#>  5            foo-TEST-drive-mv
#>  6       foo-TEST-drive-publish
#>  7   foo_pdf-TEST-drive-publish
#>  8 foo_sheet-TEST-drive-publish
#>  9   foo_doc-TEST-drive-publish
#> 10         bar-TEST-drive-share
#> # ... with 142 more rows, and 2 more variables: id <chr>,
#> #   files_resource <list>
```

You can narrow the query by specifying a `pattern` you'd like to match names against. Or by specifying a file type: the `type` argument understands MIME types, file extensions, and a few human-friendly keywords.

``` r
drive_search(pattern = "chicken")
drive_search(type = "spreadsheet")     ## Google Sheets!
drive_search(type = "csv")             ## MIME type = "text/csv"
drive_search(type = "application/pdf") ## MIME type = "application/pdf"
```

Alternatively, you can refine the search using the `q` query parameter. Accepted search clauses can be found in the [Google Drive API documentation](https://developers.google.com/drive/v3/web/search-parameters). For example, to get all files with `'horsebean'` somewhere in their full text (such as files based on the `chickwts` dataset!), do this:

``` r
(fls <- drive_search(q = "fullText contains 'horsebean'"))
#> # A tibble: 7 x 3
#>                            name
#> *                         <chr>
#> 1                  test12334556
#> 2                        foobar
#> 3                        foobar
#> 4                      chickwts
#> 5   chickwts-TEST-drive-publish
#> 6                      Untitled
#> 7 chickwts_gdoc-TEST-drive-list
#> # ... with 2 more variables: id <chr>, files_resource <list>
```

You often want to store the result of a googledrive call, so you can act on those files in the future.

#### Identify files

In addition to `drive_search()`, you can also identify files by name (path, really) using `drive_path()` or by Drive file id using `drive_get()`.

``` r
## identify file by path
(x <- drive_path("~/abc/def"))
#> # A tibble: 1 x 3
#>    name                           id files_resource
#> * <chr>                        <chr>         <list>
#> 1   def 0B0Gh-SuuA2nTMzc3eXlCRVFvbjA    <list [30]>

## let's grab that file id and retrieve it that way
x$id
#> [1] "0B0Gh-SuuA2nTMzc3eXlCRVFvbjA"
drive_get(x$id)
#> # A tibble: 1 x 3
#>    name                           id files_resource
#> * <chr>                        <chr>         <list>
#> 1   def 0B0Gh-SuuA2nTMzc3eXlCRVFvbjA    <list [30]>
```

In general, googledrive functions that operate on files allow you to specify the file(s) by name/path, file id, or in a `dribble`. If it's ambiguous, use `as_id()` to flag a character vector as holding Drive file ids as opposed to file paths. This function can also extract file ids from various URLs.

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
#> 1 README-chickwts.csv 0B0Gh-SuuA2nTc3dLU290LUdlb28    <list [36]>
```

Notice that file was uploaded as `text/csv`. Since this was a `.csv` document, and we didn't specify the type, googledrive assumed it was to be uploaded as such (`?drive_upload` for a full list of assumptions). We can overrule this by using the `type` parameter to have it load as a Google Spreadsheet. Let's delete this file first.

``` r
## example of using a dribble as input
drive_chickwts <- drive_chickwts %>%
  drive_delete()
#> Files deleted:
#>   * README-chickwts.csv: 0B0Gh-SuuA2nTc3dLU290LUdlb28

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
#> 1 2017-06-29 22:08:33        1      TRUE         TRUE
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
#> [1] "https://docs.google.com/spreadsheets/d/1L3jP5C3vK5wznjrcLlcJbjzjD_q3l0DSSjOR02RoEA4/edit?usp=drivesdk"
```

#### Download files

##### Google files

We can download files from Google Drive. Native Google file types (such as Google Documents, Google Sheets, Google Slides, etc.) need to be exported to some conventional file type. Specify this explicitly via `type` or implicitly via the file extension in `out_path`. There is also a default export type, as a last resort. For example, if I would like to download the "538-star-wars-survey" Google Sheet as a `.csv` I could run the following.

``` r
drive_download("538-star-wars-survey", type = "csv")
#> File downloaded from Google Drive:
#> '538-star-wars-survey'
#> Saved locally as:
#> '538-star-wars-survey.csv'
```

Alternatively, I could specify the `out_path` parameter.

``` r
drive_download(
  "538-star-wars-survey",
  path = "538-star-wars-survey.csv",
  overwrite = TRUE
)
#> File downloaded from Google Drive:
#> '538-star-wars-survey'
#> Saved locally as:
#> '538-star-wars-survey.csv'
```

Notice in the example above, I specified `overwrite = TRUE`. This allowed me to overwrite the file previously saved.

Finally, you could allow it to be downloaded as an Excel workbook, which is the default:

``` r
drive_download("538-star-wars-survey")
#> File downloaded from Google Drive:
#> '538-star-wars-survey'
#> Saved locally as:
#> '538-star-wars-survey.xlsx'
```

##### All other files

Downloading files that are *not* Google type files is even simpler, i.e. it does not require any conversion or type info.

``` r
## upload something we can download
boring <- drive_upload(system.file("DESCRIPTION"), name = "boring-text.txt")
#> File uploaded to Google Drive:
#> boring-text.txt
#> with MIME type:
#> text/plain

## download it and prove we got it
drive_download("boring-text.txt")
#> File downloaded from Google Drive:
#> 'boring-text.txt'
#> Saved locally as:
#> 'boring-text.txt'
readLines("boring-text.txt") %>% head()
#> [1] "Package: base"                                 
#> [2] "Version: 3.3.3"                                
#> [3] "Priority: base"                                
#> [4] "Title: The R Base Package"                     
#> [5] "Author: R Core Team and contributors worldwide"
#> [6] "Maintainer: R Core Team <R-core@r-project.org>"
```

#### Clean up

``` r
drive_chickwts %>%
  drive_delete()
#> Files deleted:
#>   * README-chickwts.csv: 1L3jP5C3vK5wznjrcLlcJbjzjD_q3l0DSSjOR02RoEA4
boring %>%
  drive_delete()
#> Files deleted:
#>   * boring-text.txt: 0B0Gh-SuuA2nTNVRSQVBFdktCTVk
```
