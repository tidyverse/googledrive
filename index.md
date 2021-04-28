
# googledrive

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/googledrive)](https://cran.r-project.org/package=googledrive)
[![Travis Build
Status](https://travis-ci.org/tidyverse/googledrive.svg?branch=master)](https://travis-ci.org/tidyverse/googledrive)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/tidyverse/googledrive?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/googledrive)
[![Coverage
Status](https://img.shields.io/codecov/c/github/tidyverse/googledrive/master.svg)](https://codecov.io/github/tidyverse/googledrive?branch=master)

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
#> # A tibble: 12 x 3
#>    name                id                                drive_resource   
#>  * <chr>               <chr>                             <list>           
#>  1 Rlogo.pdf           1opPZyo4WUiue56qlF8SO5ipaTJwPLzZg <named list [39]>
#>  2 THANKS              1JCQ06Wj6AjntiyjnHsXmmcHZWCkBNgBJ <named list [39]>
#>  3 googledrive-NEWS.md 1wMnFwFSIG0eQ4UUUEbn6-udF3GoKY3xN <named list [38]>
#>  4 def                 12xjsE3eIf84VSFF5hNhSEOnQF8DDSHkc <named list [32]>
#>  5 abc                 1qkS667DEnvDzTuVBSyj5NeGzIGbrAy9Q <named list [32]>
#>  6 BioC_mirrors.csv    1f-Ua7sUZq1g5YycA1mXwlVRrYn1lN15o <named list [38]>
#>  7 logo.jpg            1yhwnYA0TfXZ5lykclxIPyjvSBLL3h_Y0 <named list [40]>
#>  8 Rlogo.svg           1vhSTljYBXwOqILwgZ8hC3XKzVC98I5x3 <named list [40]>
#>  9 DESCRIPTION         1U4iwGpIa1SVPuiki3bs2fS-EltIvL3JD <named list [39]>
#> 10 chicken.txt         1af6w2ZU-JjwI7jrKW1OGiiRbM2GMTbil <named list [39]>
#> 11 chicken.pdf         1nL7iro5YQLt1d77acGiHoawmPTWonh6p <named list [39]>
#> 12 chicken.jpg         1QQhNDl_f2W-UxacIfCBaftUopfqi1Tw1 <named list [40]>
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
#> # A tibble: 2 x 3
#>   name      id                                drive_resource   
#> * <chr>     <chr>                             <list>           
#> 1 Rlogo.pdf 1opPZyo4WUiue56qlF8SO5ipaTJwPLzZg <named list [39]>
#> 2 THANKS    1JCQ06Wj6AjntiyjnHsXmmcHZWCkBNgBJ <named list [39]>
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
#> # A tibble: 1 x 4
#>   name            path                  id                      drive_resource  
#>   <chr>           <chr>                 <chr>                   <list>          
#> 1 googledrive-NE… ~/abc/def/googledriv… 1wMnFwFSIG0eQ4UUUEbn6-… <named list [38…
```

`as_id()` can be used to coerce various inputs into a marked vector of
file ids. It works on file ids (for obvious reasons!), various forms of
Drive URLs, and dribbles.

``` r
x$id
#> [1] "1wMnFwFSIG0eQ4UUUEbn6-udF3GoKY3xN"

# let's retrieve same file by id (also a great way to force-refresh metadata)
drive_get(as_id(x$id))
#> # A tibble: 1 x 3
#>   name                id                                drive_resource   
#> * <chr>               <chr>                             <list>           
#> 1 googledrive-NEWS.md 1wMnFwFSIG0eQ4UUUEbn6-udF3GoKY3xN <named list [38]>
drive_get(as_id(x))
#> # A tibble: 1 x 3
#>   name                id                                drive_resource   
#> * <chr>               <chr>                             <list>           
#> 1 googledrive-NEWS.md 1wMnFwFSIG0eQ4UUUEbn6-udF3GoKY3xN <named list [38]>
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
  drive_example("chicken.csv"),
  "index-chicken.csv"
))
#> Local file:
#> • '/Users/jenny/Library/R/4.0/library/googledrive/extdata/chicken.csv'
#> Uploaded into Drive file:
#> • index-chicken.csv <id: 1E9M-4etojxjfsGbwCtsc7kZPJMleGo8f>
#> With MIME type:
#> • 'text/csv'
#> # A tibble: 1 x 3
#>   name              id                                drive_resource   
#> * <chr>             <chr>                             <list>           
#> 1 index-chicken.csv 1E9M-4etojxjfsGbwCtsc7kZPJMleGo8f <named list [38]>
```

Notice that file was uploaded as `text/csv`. Since this was a `.csv`
document, and we didn’t specify the type, googledrive guessed the MIME
type. We can overrule this by using the `type` parameter to upload as a
Google Spreadsheet. Let’s delete this file first.

``` r
drive_rm(chicken)
#> File deleted:
#> • index-chicken.csv <id: 1E9M-4etojxjfsGbwCtsc7kZPJMleGo8f>

# example of using a dribble as input
chicken_sheet <- drive_upload(
  drive_example("chicken.csv"),
  "index-chicken-sheet",
  type = "spreadsheet"
)
#> Local file:
#> • '/Users/jenny/Library/R/4.0/library/googledrive/extdata/chicken.csv'
#> Uploaded into Drive file:
#> • index-chicken-sheet <id: 1ytBqCIcUoVwXRB3xIc2xVdjsauX-067HxZNh4beTNR4>
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
#> # A tibble: 1 x 5
#>   name         shared id                       drive_resource  permissions_reso…
#> * <chr>        <lgl>  <chr>                    <list>          <list>           
#> 1 index-chick… FALSE  1ytBqCIcUoVwXRB3xIc2xVd… <named list [3… <named list [2]>
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
#> • index-chicken-sheet <id: 1ytBqCIcUoVwXRB3xIc2xVdjsauX-067HxZNh4beTNR4>
#> # A tibble: 1 x 5
#>   name         shared id                       drive_resource  permissions_reso…
#> * <chr>        <lgl>  <chr>                    <list>          <list>           
#> 1 index-chick… TRUE   1ytBqCIcUoVwXRB3xIc2xVd… <named list [3… <named list [2]>
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
#> # A tibble: 1 x 7
#>   name   published shared id    drive_resource permissions_res… revision_resour…
#> * <chr>  <lgl>     <lgl>  <chr> <list>         <list>           <list>          
#> 1 index… FALSE     TRUE   1ytB… <named list [… <named list [2]> <named list [7]>
```

By default, `drive_publish()` will publish your most recent version.

``` r
(chicken_sheet <- drive_publish(chicken_sheet))
#> File now published:
#> • index-chicken-sheet <id: 1ytBqCIcUoVwXRB3xIc2xVdjsauX-067HxZNh4beTNR4>
#> # A tibble: 1 x 7
#>   name   published shared id    drive_resource permissions_res… revision_resour…
#> * <chr>  <lgl>     <lgl>  <chr> <list>         <list>           <list>          
#> 1 index… TRUE      TRUE   1ytB… <named list [… <named list [2]> <named list [9]>
```

#### Download files

##### Google files

We can download files from Google Drive. Native Google file types (such
as Google Documents, Google Sheets, Google Slides, etc.) need to be
exported to some conventional file type. There are reasonable defaults
or you can specify this explicitly via `type` or implicitly via the file
extension in `path`. For example, if I would like to download the
“chicken\_sheet” Google Sheet as a `.csv` I could run the following.

``` r
drive_download("index-chicken-sheet", type = "csv")
#> File downloaded:
#> • index-chicken-sheet <id: 1ytBqCIcUoVwXRB3xIc2xVdjsauX-067HxZNh4beTNR4>
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
#> • index-chicken-sheet <id: 1ytBqCIcUoVwXRB3xIc2xVdjsauX-067HxZNh4beTNR4>
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
#> • index-chicken-sheet <id: 1ytBqCIcUoVwXRB3xIc2xVdjsauX-067HxZNh4beTNR4>
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
#> • chicken.txt <id: 1af6w2ZU-JjwI7jrKW1OGiiRbM2GMTbil>
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
#> • index-chicken-sheet <id: 1ytBqCIcUoVwXRB3xIc2xVdjsauX-067HxZNh4beTNR4>
```

## Privacy

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)
