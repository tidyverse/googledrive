
<!-- README.md is generated from README.Rmd. Please edit that file -->
googledrive
===========

[![Build Status](https://travis-ci.org/tidyverse/googledrive.svg?branch=master)](https://travis-ci.org/tidyverse/googledrive)[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/tidyverse/googledrive?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/googledrive)[![Coverage Status](https://img.shields.io/codecov/c/github/tidyverse/googledrive/master.svg)](https://codecov.io/github/tidyverse/googledrive?branch=master)

🚧 WARNING: this is very much under construction 🚧

Overview
--------

`googledrive` interfaces with Google Drive from R, allowing users to seamlessly manage files on Google Drive from the comfort of their console 🏠.

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

### Package idiosyncrasies

-   All functions begin with the prefix `drive_`
-   Functions and parameters attempt to mimic local file navigating conventions in `R`, such as `list.files`.

### Quick demo

Here's how to list the most recently modified 100 files on your drive. This will kick off your authentication, so you will be sent to your browser to authorize your Google Drive access. The functions here are designed to be pipeable, using `%>%`, however they can also be implemented without.

``` r
drive_list()
```

You can narrow the query by specifying a `path` and/or `pattern` you'd like to search within. For example, to search within the folder `foo` for a file named `bar` you could run the following.

``` r
drive_list(path = "foo", pattern = "bar")
```

Alternatively, you can pass query parameters to `q` parameter. Accepted search parameters can be found in the [Google Drive API documentation](https://developers.google.com/drive/v3/web/search-parameters). For example, if I wanted to search for all spreadsheets, I could run the following.

``` r
drive_list(q = "mimeType='application/vnd.google-apps.spreadsheet'")
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
#> File owner: Lucy D'Agostino 
#> File type: document 
#> Last modified: 2017-05-16 
#> Access: Shared with specific people.
```

Notice that file was uploaded as a `document`. Since this was a `.txt` document, and we didn't specify the type, `googledrive` assumed it was a document (`?drive_upload` for a full list of assumptions). We can overrule this by using the `type` parameter. Let's delete this file first.

``` r
drive_chickwts <- drive_chickwts %>%
  drive_delete
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
#> File owner: Lucy D'Agostino 
#> File type: spreadsheet 
#> Last modified: 2017-05-16 
#> Access: Shared with specific people.
```

Much better 🎉.

#### Share files

Notice the access here says "Shared with specific people". To update the access, we need to change the sharing permissions. Let's say I want anyone with the link to be able to view my dataset.

``` r
drive_chickwts <- drive_chickwts %>%
  drive_share(role = "reader", type = "anyone")
#> The permissions for file 'chickwts' have been updated
```

*Notice when I run any of the `googledrive` functions, I am assigning them. This is good practice, since each of these functions is inherintely changing our file on Google Drive, so we want to keep track of that with our `R` object.*

We can then extract a share link.

``` r
drive_chickwts %>%
  drive_share_link
#> [1] "https://docs.google.com/spreadsheets/d/152-RdhgMnxiQwvNghvx8wl4HK3Ebh54sYvcASR2a7us/edit?usp=drivesdk"
```

#### Clean up

``` r
drive_chickwts %>%
  drive_delete
#> The file 'chickwts' has been deleted from your Google Drive
```
