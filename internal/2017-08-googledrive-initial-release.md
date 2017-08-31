Untitled
================

We are tickled pink to announce the initial CRAN release of the [googledrive package](http://googledrive.tidyverse.org). This is a collaboration between Jenny Bryan and tidyverse intern, [Lucy D'Agostino McGowan](http://lucymcgowan.com/) (blog post on that coming soon!).

googledrive wraps the [Drive REST API v3](https://developers.google.com/drive/v3/web/about-sdk). The most common file operations are implemented in high-level functions designed for ease of use. You can find, list, create, trash, delete, rename, move, copy, browse, download, share and publish Drive files, including those on Team Drives.

Install googledrive with:

``` r
install.packages("googledrive")
```

The auth flow should "just work" for most people, especially for early and interactive use. For more advanced usage, functions are available that give the user much more control, i.e. to support non-interactive and remote usage. A low-level interface, used internally, is also exposed for those who wish to program around the Drive API.

First use
---------

You can see and filter your files, similar to the experience at <https://drive.google.com/>, with `drive_find()`. Expect to be taken to the browser here, in order to authorize googledrive to act on your behalf. We limit `drive_find()` to 10 files and just a few file types for brevity.

``` r
library(googledrive)
(x <- drive_find(n_max = 10, type = c("spreadsheet", "jpg", "pdf")))
#> Auto-refreshing stale OAuth token.
#> # A tibble: 10 x 3
#>                             name
#>  *                         <chr>
#>  1                   chicken.jpg
#>  2            README-mirrors.csv
#>  3            README-mirrors.csv
#>  4                      logo.jpg
#>  5                     sheet-xyz
#>  6                      logo.jpg
#>  7                         test2
#>  8    foo_pdf-TEST-drive-publish
#>  9  foo_sheet-TEST-drive-publish
#> 10 export-mime-type-defaults.csv
#> # ... with 2 more variables: id <chr>, drive_resource <list>
```

googledrive holds Drive file info in a [dribble](http://googledrive.tidyverse.org/reference/dribble.html), a "Drive tibble". This allows us to provide human-readable file names, packaged with API-friendly file ids and other useful metadata in the `drive_resource` list-column. Each row represents a Drive file.

`drive_reveal()` adds extra information to the dribble by excavating interesting metadata out of `drive_resource` or by making additional API calls.

``` r
(x <- x %>%
   drive_reveal("permissions") %>% 
   drive_reveal("mime_type"))
#> # A tibble: 10 x 6
#>                             name                               mime_type
#>                            <chr>                                   <chr>
#>  1                   chicken.jpg                              image/jpeg
#>  2            README-mirrors.csv application/vnd.google-apps.spreadsheet
#>  3            README-mirrors.csv application/vnd.google-apps.spreadsheet
#>  4                      logo.jpg                              image/jpeg
#>  5                     sheet-xyz application/vnd.google-apps.spreadsheet
#>  6                      logo.jpg                              image/jpeg
#>  7                         test2 application/vnd.google-apps.spreadsheet
#>  8    foo_pdf-TEST-drive-publish                         application/pdf
#>  9  foo_sheet-TEST-drive-publish application/vnd.google-apps.spreadsheet
#> 10 export-mime-type-defaults.csv application/vnd.google-apps.spreadsheet
#> # ... with 4 more variables: shared <lgl>, id <chr>,
#> #   drive_resource <list>, permissions_resource <list>
```

Since files are stored in a specialized tibble, you can use your usual tidyverse workflows to manipulate this data frame.

``` r
x %>% 
  filter(mime_type == "image/jpeg") %>% 
  select(name, id, drive_resource)
#> # A tibble: 3 x 3
#>          name                           id drive_resource
#> *       <chr>                        <chr>         <list>
#> 1 chicken.jpg 0B0Gh-SuuA2nTbEhtYnIzcFNfX3M    <list [39]>
#> 2    logo.jpg 0B0Gh-SuuA2nTLVE0VGZQVU40Z0U    <list [38]>
#> 3    logo.jpg 0B0Gh-SuuA2nTZjlpQmlVTm9BcVU    <list [38]>
```

Test drive and cleanup
----------------------

We'll quickly show off a few basic file operations and then clean up. This example also demonstrates the file conversion features available when importing into and exporting out of native Google file types.

First, we make a new folder. Then we make a new Drive file (a Google Sheet) by uploading a local file (csv). A few example files ship with googledrive and `drive_example()` is just a convenience function to get the local path on any system.

``` r
folder <- drive_mkdir("blog-folder")
#> Folder created:
#>   * blog-folder

chicken_sheet <- drive_example("chicken.csv") %>% 
  drive_upload(path = "blog-folder/blog-chicken-sheet", type = "spreadsheet")
#> Local file:
#>   * /Users/jenny/resources/R/library/googledrive/extdata/chicken.csv
#> uploaded into Drive file:
#>   * blog-chicken-sheet: 1qGE2yLpe4qN-wZCMCl1t5ml-0acGW-xEPZ2l6PMHd7o
#> with MIME type:
#>   * application/vnd.google-apps.spreadsheet
```

Let's list the contents of the folder and reveal file path to confirm the new file exists and has been placed in the target folder.

``` r
drive_ls(folder) %>%
  drive_reveal("path")
#> # A tibble: 1 x 4
#>                 name                             path
#> *              <chr>                            <chr>
#> 1 blog-chicken-sheet ~/blog-folder/blog-chicken-sheet
#> # ... with 2 more variables: id <chr>, drive_resource <list>
```

Here we rename the file and download it to a local file. Since we are downloading from a Google Sheet, we must convert to a more conventional file type, such as csv or, the default, an Excel workbook.

``` r
chicken_sheet %>% 
  drive_rename("blog-famous-chickens") %>% 
  drive_download()
#> File renamed:
#>   * blog-chicken-sheet -> blog-famous-chickens
#> File downloaded:
#>   * blog-famous-chickens
#> Saved locally as:
#>   * blog-famous-chickens.xlsx
```

Finally, we clean up by deleting the local spreadsheet, as well as the folder we created on Drive.

``` r
file.remove("blog-famous-chickens.xlsx")
#> [1] TRUE
drive_rm(folder)
#> Files deleted:
#>   * blog-folder: 0B0Gh-SuuA2nTMTl0cjIwZThQRzg
```

We look forward to hearing how this package is useful to you. Feel free to chime in on [GitHub issues](https://github.com/tidyverse/googledrive/issues) to discuss how googledrive can best support your workflows.

Learn more about googledrive at:

-   <http://googledrive.tidyverse.org>
