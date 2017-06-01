
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
-   Functions and parameters attempt to mimic local file navigating conventions in R, such as `list.files()`.

### Quick demo

Here's how to list the most recently modified 100 files on your drive. This will kick off your authentication, so you will be sent to your browser to authorize your Google Drive access. The functions here are designed to be pipeable, using `%>%`, however they can also be implemented without.

``` r
drive_search()
#> # A tibble: 100 x 5
#>                                name                              type
#>                               <chr>                             <chr>
#>  1            foo-TEST-drive-search                            folder
#>  2                              foo application/x-www-form-urlencoded
#>  3                    chickwts1.csv                          text/csv
#>  4                        file_test                          document
#>  5                       unconftest                          document
#>  6      chickwts-TEST-drive-publish                        text/plain
#>  7  chickwts_txt-TEST-drive-publish                        text/plain
#>  8 chickwts_gdoc-TEST-drive-publish                          document
#>  9    chickwts_gdoc-TEST-drive-list                          document
#> 10             foo2-TEST-drive-list                            folder
#> # ... with 90 more rows, and 3 more variables: parents <list>, id <chr>,
#> #   gfile <list>
```

You can narrow the query by specifying a `pattern` you'd like to match names against.

``` r
drive_search(pattern = "baz")
```

Alternatively, you can refine the search using the `q` query parameter. Accepted search clauses can be found in the [Google Drive API documentation](https://developers.google.com/drive/v3/web/search-parameters). For example, if I wanted to search for all spreadsheets, I could run the following.

``` r
drive_search(q = "mimeType = 'application/vnd.google-apps.spreadsheet'")
#> # A tibble: 2 x 5
#>                   name        type    parents
#>                  <chr>       <chr>     <list>
#> 1     Copy of chickwts spreadsheet <list [1]>
#> 2 538-star-wars-survey spreadsheet <list [1]>
#> # ... with 2 more variables: id <chr>, gfile <list>
```

#### Upload files

We can upload any file type.

``` r
write.csv(chickwts, "chickwts.csv")
drive_chickwts <- drive_upload("chickwts.csv")
#> File uploaded to Google Drive:
#> chickwts.csv
#> with MIME type:
#> text/csv
```

We now have a file of class `gfile` that contains information about the uploaded file.

``` r
drive_chickwts
#> File name: chickwts.csv 
#> File owner: tidyverse testdrive 
#> File type: text/csv 
#> Last modified: 2017-06-01 
#> Access: Shared with specific people.
```

Notice that file was uploaded as a `document`. Since this was a `.csv` document, and we didn't specify the type, `googledrive` assumed it was to be uploaded as such (`?drive_upload` for a full list of assumptions). We can overrule this by using the `type` parameter to have it load as a Google Spreadsheet. Let's delete this file first.

``` r
drive_chickwts <- drive_chickwts %>%
  drive_delete()
#> The file 'chickwts.csv' has been deleted from your Google Drive
```

``` r
drive_chickwts <- drive_upload("chickwts.csv", type = "spreadsheet")
#> File uploaded to Google Drive:
#> chickwts
#> with MIME type:
#> application/vnd.google-apps.spreadsheet
```

Let's see if that worked.

``` r
drive_chickwts
#> File name: chickwts 
#> File owner: tidyverse testdrive 
#> File type: spreadsheet 
#> Last modified: 2017-06-01 
#> Access: Shared with specific people.
```

Much better!

#### Publish files

Versions of Google Documents, Sheets, and Presentations can be published online. By default, `drive_publish()` will publish your most recent version. You can check your publication status by running `drive_check_publish()`.

``` r
drive_check_publish(drive_chickwts)
#> The latest revision of the Google Drive file 'chickwts' is not published.
```

``` r
drive_chickwts <- drive_publish(drive_chickwts)
#> You have changed the publication status of 'chickwts'.
drive_chickwts$publish
#> # A tibble: 1 x 4
#>            check_time revision published auto_publish
#>                <dttm>    <chr>     <lgl>        <lgl>
#> 1 2017-05-31 20:57:36        3      TRUE         TRUE
```

``` r
drive_check_publish(drive_chickwts)
#> The latest revision of Google Drive file 'chickwts' is published.
```

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
#> [1] "https://docs.google.com/spreadsheets/d/1vmNKiM4tSgDeQbFcfs5pre5MBhazTJjjoh7PzRPLQiw/edit?usp=drivesdk"
```

#### Clean up

``` r
drive_chickwts %>%
  drive_delete()
#> The file 'chickwts' has been deleted from your Google Drive
```
