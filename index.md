
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

  - Most functions begin with the prefix `drive_`. Auto-completion is
    your friend.
  - Goal is to allow Drive access that feels similar to Unix file system
    utilities, e.g., `find`, `ls`, `mv`, `cp`, `mkdir`, and `rm`.
  - The metadata for one or more Drive files is held in a `dribble`, a
    “Drive tibble”. This is a data frame with one row per file. A
    dribble is returned (and accepted) by almost every function in
    googledrive. Design goals:
      - Give humans what they want: the file name
      - Track what the API wants: the file ID
      - Hold on to all the other metadata sent back by the API
  - googledrive is “pipe-friendly” and, in fact, re-exports `%>%`, but
    does not require its use.

### Quick demo

Here’s how to list up to `n_max` of the files you see in [My
Drive](https://drive.google.com). You can expect to be sent to your
browser here, to authenticate yourself and authorize the googledrive
package to deal on your behalf with Google Drive.

``` r
drive_find(n_max = 30)
#> # A tibble: 14 x 3
#>    name                    id                              drive_resource  
#>  * <chr>                   <chr>                           <list>          
#>  1 Rlogo.pdf               1cn7oVxQRgD0l_hCI4nrSSWrKeVFys… <named list [39…
#>  2 THANKS                  1zNZpVO4MCjNUFUHOwSv3WlyUh4Dq_… <named list [39…
#>  3 chicken-perm-article.t… 1oWpfPYR-77c-DdvoW30682F9Gde8Z… <named list [39…
#>  4 googledrive-NEWS.md     15pfwRfXvpxekxhdERmSUnoxQY5K70… <named list [38…
#>  5 def                     1hr4EFw3r5vAMm5Jgw2SsFluBpN-oA… <named list [32…
#>  6 abc                     11lidFPceZAcNTHasQARiwAhE0NgmS… <named list [32…
#>  7 BioC_mirrors.csv        1vV0fPdNOyo3Ti9ofA38MuTQm27pXv… <named list [38…
#>  8 logo.jpg                1OFeNdd63NfoavqvDf5-xa3LORiamf… <named list [40…
#>  9 Rlogo.svg               11sxsw-ux-UjQjzVdxd1wjNz37hJeB… <named list [40…
#> 10 DESCRIPTION             1MjV4stVPhlMNz1AcrIizcL7yTcVaR… <named list [39…
#> 11 chicken.txt             1xmwFZ_UN-CSs3Ic2aPUw22DbxZxoe… <named list [39…
#> 12 chicken.pdf             1eK9ozP1TZjXfAgaAGmP9GrUTovGUa… <named list [39…
#> 13 chicken.jpg             1JnGjIdruQXErd20xR_ecAzN3yP_fT… <named list [40…
#> 14 chicken.csv             1eHoOi9Ch3zk3_QBRKCJajFEIO4aeG… <named list [38…
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
by “anyone with a link”, do
this:

``` r
(files <- drive_find(q = c("starred = true", "visibility = 'anyoneWithLink'")))
#> # A tibble: 2 x 3
#>   name      id                                drive_resource   
#> * <chr>     <chr>                             <list>           
#> 1 Rlogo.pdf 1cn7oVxQRgD0l_hCI4nrSSWrKeVFysUp7 <named list [39]>
#> 2 THANKS    1zNZpVO4MCjNUFUHOwSv3WlyUh4Dq_du3 <named list [39]>
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
#>   name           path                 id                    drive_resource 
#>   <chr>          <chr>                <chr>                 <list>         
#> 1 googledrive-N… ~/abc/def/googledri… 15pfwRfXvpxekxhdERmS… <named list [3…
```

`as_id()` can be used to coerce various inputs into a marked vector of
file ids. It works on file ids (for obvious reasons\!), various forms of
Drive URLs, and
dribbles.

``` r
## let's retrieve same file by id (also a great way to force-refresh metadata)
x$id
#> [1] "15pfwRfXvpxekxhdERmSUnoxQY5K701y7"
drive_get(as_id(x$id))
#> # A tibble: 1 x 3
#>   name                id                                drive_resource   
#> * <chr>               <chr>                             <list>           
#> 1 googledrive-NEWS.md 15pfwRfXvpxekxhdERmSUnoxQY5K701y7 <named list [38]>
drive_get(as_id(x))
#> # A tibble: 1 x 3
#>   name                id                                drive_resource   
#> * <chr>               <chr>                             <list>           
#> 1 googledrive-NEWS.md 15pfwRfXvpxekxhdERmSUnoxQY5K701y7 <named list [38]>
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
  "README-chicken.csv"
))
#> Local file:
#>   * /Users/jenny/Library/R/3.6/library/googledrive/extdata/chicken.csv
#> uploaded into Drive file:
#>   * README-chicken.csv: 1mjn-J_HbyfQisV3Kpl__C5IBLFiGW-1X
#> with MIME type:
#>   * text/csv
#> # A tibble: 1 x 3
#>   name               id                                drive_resource   
#> * <chr>              <chr>                             <list>           
#> 1 README-chicken.csv 1mjn-J_HbyfQisV3Kpl__C5IBLFiGW-1X <named list [38]>
```

Notice that file was uploaded as `text/csv`. Since this was a `.csv`
document, and we didn’t specify the type, googledrive guessed the MIME
type. We can overrule this by using the `type` parameter to upload as a
Google Spreadsheet. Let’s delete this file first.

``` r
drive_rm(chicken)
#> Files deleted:
#>   * README-chicken.csv: 1mjn-J_HbyfQisV3Kpl__C5IBLFiGW-1X

## example of using a dribble as input
chicken_sheet <- drive_upload(
  drive_example("chicken.csv"),
  "README-chicken-sheet",
  type = "spreadsheet"
)
#> Local file:
#>   * /Users/jenny/Library/R/3.6/library/googledrive/extdata/chicken.csv
#> uploaded into Drive file:
#>   * README-chicken-sheet: 1j2VsF1NcYlc6W9OwenhhMijl7u7HOxpdDXY9UJrg_SM
#> with MIME type:
#>   * application/vnd.google-apps.spreadsheet
```

Much better\!

#### Share files

To allow other people to access your file, you need to change the
sharing permissions. You can check the sharing status by running
`drive_reveal(..., "permissions")`, which adds a logical column `shared`
and parks more detailed metadata in a `permissions_resource` variable.

``` r
chicken_sheet %>% 
  drive_reveal("permissions")
#> # A tibble: 1 x 5
#>   name        shared id                   drive_resource  permissions_reso…
#> * <chr>       <lgl>  <chr>                <list>          <list>           
#> 1 README-chi… FALSE  1j2VsF1NcYlc6W9Owen… <named list [3… <named list [2]>
```

Here’s how to grant anyone with the link permission to view this data
set.

``` r
(chicken_sheet <- chicken_sheet %>%
   drive_share(role = "reader", type = "anyone"))
#> Permissions updated
#>   * role = reader
#>   * type = anyone
#> For files:
#>   * README-chicken-sheet: 1j2VsF1NcYlc6W9OwenhhMijl7u7HOxpdDXY9UJrg_SM
#> # A tibble: 1 x 5
#>   name        shared id                   drive_resource  permissions_reso…
#> * <chr>       <lgl>  <chr>                <list>          <list>           
#> 1 README-chi… TRUE   1j2VsF1NcYlc6W9Owen… <named list [3… <named list [2]>
```

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
#>   name  published shared id    drive_resource permissions_res…
#> * <chr> <lgl>     <lgl>  <chr> <list>         <list>          
#> 1 READ… FALSE     TRUE   1j2V… <named list [… <named list [2]>
#> # … with 1 more variable: revision_resource <list>
```

By default, `drive_publish()` will publish your most recent version.

``` r
(chicken_sheet <- drive_publish(chicken_sheet))
#> Files now published:
#>   * README-chicken-sheet: 1j2VsF1NcYlc6W9OwenhhMijl7u7HOxpdDXY9UJrg_SM
#> # A tibble: 1 x 7
#>   name  published shared id    drive_resource permissions_res…
#> * <chr> <lgl>     <lgl>  <chr> <list>         <list>          
#> 1 READ… TRUE      TRUE   1j2V… <named list [… <named list [2]>
#> # … with 1 more variable: revision_resource <list>
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
drive_download("README-chicken-sheet", type = "csv")
#> File downloaded:
#>   * README-chicken-sheet
#> Saved locally as:
#>   * README-chicken-sheet.csv
```

Alternatively, I could specify type via the `path` parameter.

``` r
drive_download(
  "README-chicken-sheet",
  path = "README-chicken-sheet.csv",
  overwrite = TRUE
)
#> File downloaded:
#>   * README-chicken-sheet
#> Saved locally as:
#>   * README-chicken-sheet.csv
```

Notice in the example above, I specified `overwrite = TRUE`, in order to
overwrite the local csv file previously saved.

Finally, you could just allow export to the default type. In the case of
Google Sheets, this is an Excel workbook:

``` r
drive_download("README-chicken-sheet")
#> File downloaded:
#>   * README-chicken-sheet
#> Saved locally as:
#>   * README-chicken-sheet.xlsx
```

##### All other files

Downloading files that are *not* Google type files is even simpler,
i.e. it does not require any conversion or type info.

``` r
## download it and prove we got it
drive_download("chicken.txt")
#> File downloaded:
#>   * chicken.txt
#> Saved locally as:
#>   * chicken.txt
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
drive_rm(chicken_sheet)
#> Files deleted:
#>   * README-chicken-sheet: 1j2VsF1NcYlc6W9OwenhhMijl7u7HOxpdDXY9UJrg_SM
file.remove(c(
  "README-chicken-sheet.csv", "README-chicken-sheet.xlsx", "chicken.txt"
))
#> [1] TRUE TRUE TRUE
```

## Privacy

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)
