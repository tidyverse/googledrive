
# googledrive

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/googledrive)](https://CRAN.R-project.org/package=googledrive)
[![R-CMD-check](https://github.com/tidyverse/googledrive/workflows/R-CMD-check/badge.svg)](https://github.com/tidyverse/googledrive/actions)
[![Codecov test
coverage](https://codecov.io/gh/tidyverse/googledrive/branch/main/graph/badge.svg)](https://codecov.io/gh/tidyverse/googledrive?branch=main)
<!-- badges: end -->

## Overview

googledrive allows you to interact with files on Google Drive from R.

## Installation

Install from CRAN:

``` r
install.packages("googledrive")
```

## Usage

### Load googledrive

``` r
library("googledrive")
```

### Package conventions

- Most functions begin with the prefix `drive_`. Auto-completion is your
  friend.
- Goal is to allow Drive access that feels similar to Unix file system
  utilities, e.g., `find`, `ls`, `mv`, `cp`, `mkdir`, and `rm`.
- The metadata for one or more Drive files is held in a `dribble`, a
  “Drive tibble”. This is a data frame with one row per file. A dribble
  is returned (and accepted) by almost every function in googledrive.
  Design goals:
  - Give humans what they want: the file name
  - Track what the API wants: the file ID
  - Hold on to all the other metadata sent back by the API
- googledrive is “pipe-friendly” (either the base `|>` or magrittr `%>%`
  pipe), but does not require its use.

### Quick demo

Here’s how to list up to `n_max` of the files you see in [My
Drive](https://drive.google.com). You can expect to be sent to your
browser here, to authenticate yourself and authorize the googledrive
package to deal on your behalf with Google Drive.

``` r
drive_find(n_max = 30)
#> # A dribble: 30 × 3
#>    name                   id                                drive_resource   
#>    <chr>                  <drv_id>                          <list>           
#>  1 name-squatter-mv       1ncaT91RYOvHNg2XmrLdUOhrcypK3owCm <named list [41]>
#>  2 chicken-mv-renamed.txt 1Hu-OYuiQ7A80y1kEvT6UWDFpPkTkei2A <named list [44]>
#>  3 name-squatter-mv       1WR4vBdHvwimyLR9PIl3SSDlTmgfnLWP5 <named list [41]>
#>  4 chicken-mv-renamed.txt 16l9dZkax8CAFdOGwQ4IgVVgyFLKumyUp <named list [44]>
#>  5 name-squatter-mv       1nKweOnEis8jNzvnmAX3G0rjtak5622b- <named list [41]>
#>  6 chicken-mv-renamed.txt 1tgRTfYDyXX7TgoNnDKetfbDC3Kea_aA_ <named list [44]>
#>  7 name-squatter-mv       1QQjvI_K_robo715M_YMtwYuVuPCHt1x1 <named list [41]>
#>  8 chicken-mv-renamed.txt 1VOax5G5x28UJGANVa1x3kJRH4V76xKXz <named list [44]>
#>  9 name-squatter-mv       1uuEA1mkD7327ezEqROYKz7faZj5DsNQL <named list [41]>
#> 10 chicken-mv-renamed.txt 1-0VRv2y2k91UOiomyx2WO_C3IFJSNCjM <named list [44]>
#> # ℹ 20 more rows
```

You can narrow the query by specifying a `pattern` you’d like to match
names against. Or by specifying a file type: the `type` argument
understands MIME types, file extensions, and a few human-friendly
keywords.

``` r
drive_find(pattern = "chicken")
drive_find(type = "spreadsheet") ## Google Sheets!
drive_find(type = "csv") ## MIME type = "text/csv"
drive_find(type = "application/pdf") ## MIME type = "application/pdf"
```

Alternatively, you can refine the search using the `q` query parameter.
Accepted search clauses can be found in the [Google Drive API
documentation](https://developers.google.com/drive/v3/web/search-parameters).
For example, to see all files that you’ve starred and that are readable
by “anyone with a link”, do this:

``` r
(files <- drive_find(q = c("starred = true", "visibility = 'anyoneWithLink'")))
#> # A dribble: 2 × 3
#>   name       id                                drive_resource   
#>   <chr>      <drv_id>                          <list>           
#> 1 r_logo.jpg 1wFAZdmBiSRu4GShsqurxD7wIDSCZvPud <named list [45]>
#> 2 THANKS     19URV7BT0_E1KhYdfDODszK5aiELOwTSz <named list [44]>
```

You generally want to store the result of a googledrive call, as we do
with `files` above. `files` is a dribble with info on several files and
can be used as the input for downstream calls. It can also be
manipulated as a regular data frame at any point.

#### Identify files

`drive_find()` searches by file properties, but you can also identify
files by name (path, really) or by Drive file id using `drive_get()`.

``` r
(x <- drive_get("~/abc/def/googledrive-NEWS.md"))
#> ✔ The input `path` resolved to exactly 1 file.
#> # A dribble: 1 × 4
#>   name                path                          id       drive_resource   
#>   <chr>               <chr>                         <drv_id> <list>           
#> 1 googledrive-NEWS.md ~/abc/def/googledrive-NEWS.md 1h1lhFf… <named list [43]>
```

`as_id()` can be used to convert various inputs into a marked vector of
file ids. It works on file ids (for obvious reasons!), various forms of
Drive URLs, and `dribble`s.

``` r
x$id
#> <drive_id[1]>
#> [1] 1h1lhFfQrDZevE2OEX10-rbi2BfvGogFm

# let's retrieve same file by id (also a great way to force-refresh metadata)
drive_get(x$id)
#> # A dribble: 1 × 3
#>   name                id                                drive_resource   
#>   <chr>               <drv_id>                          <list>           
#> 1 googledrive-NEWS.md 1h1lhFfQrDZevE2OEX10-rbi2BfvGogFm <named list [43]>
drive_get(as_id(x))
#> # A dribble: 1 × 3
#>   name                id                                drive_resource   
#>   <chr>               <drv_id>                          <list>           
#> 1 googledrive-NEWS.md 1h1lhFfQrDZevE2OEX10-rbi2BfvGogFm <named list [43]>
```

In general, googledrive functions that operate on files allow you to
specify the file(s) by name/path, file id, or in a `dribble`. If it’s
ambiguous, use `as_id()` to mark a character vector as holding Drive
file ids as opposed to file paths. This function can also extract file
ids from various URLs.

#### Upload files

We can upload any file type.

``` r
(chicken <- drive_upload(
  drive_example_local("chicken.csv"),
  "index-chicken.csv"
))
#> Local file:
#> • '/private/tmp/Rtmpr2jKV8/temp_libpath11f0e41a0b00e/googledrive/extdata/example_files/chicken.csv'
#> Uploaded into Drive file:
#> • 'index-chicken.csv' <id: 1uUBGMtE27XYtNPsVwqHS9HMyC50rbGEk>
#> With MIME type:
#> • 'text/csv'
#> # A dribble: 1 × 3
#>   name              id                                drive_resource   
#>   <chr>             <drv_id>                          <list>           
#> 1 index-chicken.csv 1uUBGMtE27XYtNPsVwqHS9HMyC50rbGEk <named list [43]>
```

Notice that file was uploaded as `text/csv`. Since this was a `.csv`
document, and we didn’t specify the type, googledrive guessed the MIME
type. We can overrule this by using the `type` parameter to upload as a
Google Spreadsheet. Let’s delete this file first.

``` r
drive_rm(chicken)
#> File deleted:
#> • 'index-chicken.csv' <id: 1uUBGMtE27XYtNPsVwqHS9HMyC50rbGEk>

# example of using a dribble as input
chicken_sheet <- drive_example_local("chicken.csv") |>
  drive_upload(
    name = "index-chicken-sheet",
    type = "spreadsheet"
  )
#> Local file:
#> • '/private/tmp/Rtmpr2jKV8/temp_libpath11f0e41a0b00e/googledrive/extdata/example_files/chicken.csv'
#> Uploaded into Drive file:
#> • 'index-chicken-sheet' <id: 1iKasAIydx6y4f3Pywozn1Ek99nwnqUc-TOdEx-pXRTM>
#> With MIME type:
#> • 'application/vnd.google-apps.spreadsheet'
```

Much better!

#### Share files

To allow other people to access your file, you need to change the
sharing permissions. You can check the sharing status by running
`drive_reveal(..., "permissions")`, which adds a logical column `shared`
and parks more detailed metadata in a `permissions_resource` variable.

``` r
chicken_sheet |>
  drive_reveal("permissions")
#> # A dribble: 1 × 5
#>   name                shared id       drive_resource    permissions_resource
#>   <chr>               <lgl>  <drv_id> <list>            <list>              
#> 1 index-chicken-sheet FALSE  1iKasAI… <named list [37]> <named list [2]>
```

Here’s how to grant anyone with the link permission to view this data
set.

``` r
(chicken_sheet <- chicken_sheet |>
  drive_share(role = "reader", type = "anyone"))
#> Permissions updated:
#> • role = reader
#> • type = anyone
#> For file:
#> • 'index-chicken-sheet' <id: 1iKasAIydx6y4f3Pywozn1Ek99nwnqUc-TOdEx-pXRTM>
#> # A dribble: 1 × 5
#>   name                shared id       drive_resource    permissions_resource
#>   <chr>               <lgl>  <drv_id> <list>            <list>              
#> 1 index-chicken-sheet TRUE   1iKasAI… <named list [38]> <named list [2]>
```

This comes up so often, there’s even a convenience wrapper,
`drive_share_anyone()`.

#### Publish files

Versions of Google Documents, Sheets, and Presentations can be published
online. You can check your publication status by running
`drive_reveal(..., "published")`, which adds a logical column
`published` and parks more detailed metadata in a `revision_resource`
variable.

``` r
chicken_sheet |>
  drive_reveal("published")
#> # A dribble: 1 × 7
#>   name             published shared id       drive_resource permissions_resource
#>   <chr>            <lgl>     <lgl>  <drv_id> <list>         <list>              
#> 1 index-chicken-s… FALSE     TRUE   1iKasAI… <named list>   <named list [2]>    
#> # ℹ 1 more variable: revision_resource <list>
```

By default, `drive_publish()` will publish your most recent version.

``` r
(chicken_sheet <- drive_publish(chicken_sheet))
#> File now published:
#> • 'index-chicken-sheet' <id: 1iKasAIydx6y4f3Pywozn1Ek99nwnqUc-TOdEx-pXRTM>
#> # A dribble: 1 × 7
#>   name             published shared id       drive_resource permissions_resource
#>   <chr>            <lgl>     <lgl>  <drv_id> <list>         <list>              
#> 1 index-chicken-s… TRUE      TRUE   1iKasAI… <named list>   <named list [2]>    
#> # ℹ 1 more variable: revision_resource <list>
```

#### Download files

##### Google files

We can download files from Google Drive. Native Google file types (such
as Google Documents, Google Sheets, Google Slides, etc.) need to be
exported to some conventional file type. There are reasonable defaults
or you can specify this explicitly via `type` or implicitly via the file
extension in `path`. For example, if I would like to download the
“chicken_sheet” Google Sheet as a `.csv` I could run the following.

``` r
drive_download("index-chicken-sheet", type = "csv")
#> File downloaded:
#> • 'index-chicken-sheet' <id: 1iKasAIydx6y4f3Pywozn1Ek99nwnqUc-TOdEx-pXRTM>
#> Saved locally as:
#> • 'index-chicken-sheet.csv'
```

Alternatively, I could specify type via the `path` parameter.

``` r
drive_download(
  "index-chicken-sheet",
  path = "index-chicken-sheet.csv",
  overwrite = TRUE
)
#> File downloaded:
#> • 'index-chicken-sheet' <id: 1iKasAIydx6y4f3Pywozn1Ek99nwnqUc-TOdEx-pXRTM>
#> Saved locally as:
#> • 'index-chicken-sheet.csv'
```

Notice in the example above, I specified `overwrite = TRUE`, in order to
overwrite the local csv file previously saved.

Finally, you could just allow export to the default type. In the case of
Google Sheets, this is an Excel workbook:

``` r
drive_download("index-chicken-sheet")
#> File downloaded:
#> • 'index-chicken-sheet' <id: 1iKasAIydx6y4f3Pywozn1Ek99nwnqUc-TOdEx-pXRTM>
#> Saved locally as:
#> • 'index-chicken-sheet.xlsx'
```

##### All other files

Downloading files that are *not* Google type files is even simpler,
i.e. it does not require any conversion or type info.

``` r
# download it and prove we got it
drive_download("chicken.txt")
#> File downloaded:
#> • 'chicken.txt' <id: 1xMvlJHia_qYNZmucaStDcOF9A9PD4BOT>
#> Saved locally as:
#> • 'chicken.txt'
readLines("chicken.txt") |> head()
#> [1] "A chicken whose name was Chantecler"      
#> [2] "Clucked in iambic pentameter"             
#> [3] "It sat on a shelf, reading Song of Myself"
#> [4] "And laid eggs with a perfect diameter."   
#> [5] ""                                         
#> [6] "—Richard Maxson"
```

#### Clean up

``` r
file.remove(c(
  "index-chicken-sheet.csv",
  "index-chicken-sheet.xlsx",
  "chicken.txt"
))
#> [1] TRUE TRUE TRUE
drive_find("index-chicken") |> drive_rm()
#> File deleted:
#> • 'index-chicken-sheet' <id: 1iKasAIydx6y4f3Pywozn1Ek99nwnqUc-TOdEx-pXRTM>
```

## Privacy

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)
