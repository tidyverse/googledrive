
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

-   Most functions begin with the prefix `drive_`. Auto-completion is
    your friend.
-   Goal is to allow Drive access that feels similar to Unix file system
    utilities, e.g., `find`, `ls`, `mv`, `cp`, `mkdir`, and `rm`.
-   The metadata for one or more Drive files is held in a `dribble`, a
    “Drive tibble”. This is a data frame with one row per file. A
    dribble is returned (and accepted) by almost every function in
    googledrive. Design goals:
    -   Give humans what they want: the file name
    -   Track what the API wants: the file ID
    -   Hold on to all the other metadata sent back by the API
-   googledrive is “pipe-friendly” and, in fact, re-exports `%>%`, but
    does not require its use.

### Quick demo

Here’s how to list up to `n_max` of the files you see in [My
Drive](https://drive.google.com). You can expect to be sent to your
browser here, to authenticate yourself and authorize the googledrive
package to deal on your behalf with Google Drive.

``` r
drive_find(n_max = 30)
#> # A dribble: 30 × 3
#>    name                       id                                drive_resource  
#>    <chr>                      <drv_id>                          <list>          
#>  1 2021-09-16_r_logo.jpg      1dandXB0QZpjeGQq_56wTXKNwaqgsOa9D <named list [41…
#>  2 2021-09-16_r_about.html    1XfCI_orH4oNUZh06C4w6vXtno-BT_zmZ <named list [40…
#>  3 2021-09-16_imdb_latin1.csv 163YPvqYmGuqQiEwEFLg2s1URq4EnpkBw <named list [39…
#>  4 2021-09-16_chicken.txt     1axJz8GSmecSnaYBx0Sb3Gb-SXVaTzKw7 <named list [40…
#>  5 2021-09-16_chicken.pdf     14Hd6_VQAeEgcwBBJamc-FUlnXhp117T2 <named list [40…
#>  6 2021-09-16_chicken.jpg     1aslW1T-B8UKzAEotDWpmRFaMyMux5-it <named list [41…
#>  7 2021-09-16_chicken.csv     1Mj--zJYZJSMKsNVjk2tYFef5LnCsNoDT <named list [39…
#>  8 pqr                        143iq-CswFTwJTjVfKkcFMDW0jYqDeUj2 <named list [34…
#>  9 mno                        1gcUTnFbsF6uioJrLCsVQ78_F1wEzyNtI <named list [33…
#> 10 jkl                        17T40phn99w0hY-B_Ev0deTvVg9fmUSnt <named list [33…
#> # … with 20 more rows
```

You can narrow the query by specifying a `pattern` you’d like to match
names against. Or by specifying a file type: the `type` argument
understands MIME types, file extensions, and a few human-friendly
keywords.

``` r
drive_find(pattern = "chicken")
drive_find(type = "spreadsheet")     ## Google Sheets!
drive_find(type = "csv")             ## MIME type = "text/csv"
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
#> 1 r_logo.jpg 1wFAZdmBiSRu4GShsqurxD7wIDSCZvPud <named list [41]>
#> 2 THANKS     19URV7BT0_E1KhYdfDODszK5aiELOwTSz <named list [40]>
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
#> ✓ The input `path` resolved to exactly 1 file.
#> # A dribble: 1 × 4
#>   name                path                          id            drive_resource
#>   <chr>               <chr>                         <drv_id>      <list>        
#> 1 googledrive-NEWS.md ~/abc/def/googledrive-NEWS.md 1h1lhFfQrDZe… <named list […
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
#> 1 googledrive-NEWS.md 1h1lhFfQrDZevE2OEX10-rbi2BfvGogFm <named list [39]>
drive_get(as_id(x))
#> # A dribble: 1 × 3
#>   name                id                                drive_resource   
#>   <chr>               <drv_id>                          <list>           
#> 1 googledrive-NEWS.md 1h1lhFfQrDZevE2OEX10-rbi2BfvGogFm <named list [39]>
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
#> • '/private/tmp/RtmpIm6bTU/temp_libpath68f2f2fb7a9/googledrive/extdata/example_files/chicken.csv'
#> Uploaded into Drive file:
#> • 'index-chicken.csv' <id: 14y8vNq9VXYuOuoHsexumu4y73hqBP_RB>
#> With MIME type:
#> • 'text/csv'
#> # A dribble: 1 × 3
#>   name              id                                drive_resource   
#>   <chr>             <drv_id>                          <list>           
#> 1 index-chicken.csv 14y8vNq9VXYuOuoHsexumu4y73hqBP_RB <named list [39]>
```

Notice that file was uploaded as `text/csv`. Since this was a `.csv`
document, and we didn’t specify the type, googledrive guessed the MIME
type. We can overrule this by using the `type` parameter to upload as a
Google Spreadsheet. Let’s delete this file first.

``` r
drive_rm(chicken)
#> File deleted:
#> • 'index-chicken.csv' <id: 14y8vNq9VXYuOuoHsexumu4y73hqBP_RB>

# example of using a dribble as input
chicken_sheet <- drive_example_local("chicken.csv") %>% 
  drive_upload(
    name = "index-chicken-sheet",
    type = "spreadsheet"
  )
#> Local file:
#> • '/private/tmp/RtmpIm6bTU/temp_libpath68f2f2fb7a9/googledrive/extdata/example_files/chicken.csv'
#> Uploaded into Drive file:
#> • 'index-chicken-sheet' <id: 17oaVZ09fbpjdV-KMUdcguAD8i1hKeSjNZnq_fbR4iiw>
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
chicken_sheet %>% 
  drive_reveal("permissions")
#> # A dribble: 1 × 5
#>   name                shared id                drive_resource  permissions_reso…
#>   <chr>               <lgl>  <drv_id>          <list>          <list>           
#> 1 index-chicken-sheet FALSE  17oaVZ09fbpjdV-K… <named list [3… <named list [2]>
```

Here’s how to grant anyone with the link permission to view this data
set.

``` r
(chicken_sheet <- chicken_sheet %>%
   drive_share(role = "reader", type = "anyone"))
#> Permissions updated:
#> • role = reader
#> • type = anyone
#> For file:
#> • 'index-chicken-sheet' <id: 17oaVZ09fbpjdV-KMUdcguAD8i1hKeSjNZnq_fbR4iiw>
#> # A dribble: 1 × 5
#>   name                shared id                drive_resource  permissions_reso…
#>   <chr>               <lgl>  <drv_id>          <list>          <list>           
#> 1 index-chicken-sheet TRUE   17oaVZ09fbpjdV-K… <named list [3… <named list [2]>
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
chicken_sheet %>% 
  drive_reveal("published")
#> # A dribble: 1 × 7
#>   name   published shared id    drive_resource permissions_res… revision_resour…
#>   <chr>  <lgl>     <lgl>  <drv> <list>         <list>           <list>          
#> 1 index… FALSE     TRUE   17oa… <named list [… <named list [2]> <named list [7]>
```

By default, `drive_publish()` will publish your most recent version.

``` r
(chicken_sheet <- drive_publish(chicken_sheet))
#> File now published:
#> • 'index-chicken-sheet' <id: 17oaVZ09fbpjdV-KMUdcguAD8i1hKeSjNZnq_fbR4iiw>
#> # A dribble: 1 × 7
#>   name   published shared id    drive_resource permissions_res… revision_resour…
#>   <chr>  <lgl>     <lgl>  <drv> <list>         <list>           <list>          
#> 1 index… TRUE      TRUE   17oa… <named list [… <named list [2]> <named list [9]>
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
#> • 'index-chicken-sheet' <id: 17oaVZ09fbpjdV-KMUdcguAD8i1hKeSjNZnq_fbR4iiw>
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
#> • 'index-chicken-sheet' <id: 17oaVZ09fbpjdV-KMUdcguAD8i1hKeSjNZnq_fbR4iiw>
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
#> • 'index-chicken-sheet' <id: 17oaVZ09fbpjdV-KMUdcguAD8i1hKeSjNZnq_fbR4iiw>
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
readLines("chicken.txt") %>% head()
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
  "index-chicken-sheet.csv", "index-chicken-sheet.xlsx", "chicken.txt"
))
#> [1] TRUE TRUE TRUE
drive_find("index-chicken") %>% drive_rm()
#> File deleted:
#> • 'index-chicken-sheet' <id: 17oaVZ09fbpjdV-KMUdcguAD8i1hKeSjNZnq_fbR4iiw>
```

## Privacy

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)
