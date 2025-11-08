# Lookup MIME type

This is a helper to determine which MIME type should be used for a file.
Three types of input are acceptable:

- Native Google Drive file types. Important examples:

  - "document" for Google Docs

  - "folder" for folders

  - "presentation" for Google Slides

  - "spreadsheet" for Google Sheets

- File extensions, such as "pdf", "csv", etc.

- MIME types accepted by Google Drive (these are simply passed through).

## Usage

``` r
drive_mime_type(type = NULL)
```

## Arguments

- type:

  Character. Google Drive file type, file extension, or MIME type. Pass
  the sentinel
  [`expose()`](https://googledrive.tidyverse.org/dev/reference/expose.md)
  if you want to get the full table used for validation and lookup, i.e.
  all MIME types known to be relevant to the Drive API.

## Value

Character. MIME type.

## Examples

``` r
## get the mime type for Google Spreadsheets
drive_mime_type("spreadsheet")
#> [1] "application/vnd.google-apps.spreadsheet"

## get the mime type for jpegs
drive_mime_type("jpeg")
#> [1] "image/jpeg"

## it's vectorized
drive_mime_type(c("presentation", "pdf", "image/gif"))
#> [1] "application/vnd.google-apps.presentation"
#> [2] "application/pdf"                         
#> [3] "image/gif"                               

## see the internal tibble of MIME types known to the Drive API
drive_mime_type(expose())
#> # A tibble: 89 × 5
#>    mime_type                       ext   description human_type default
#>    <chr>                           <chr> <chr>       <chr>      <lgl>  
#>  1 application/epub+zip            epub  NA          epub       FALSE  
#>  2 application/msword              doc   NA          doc        TRUE   
#>  3 application/pdf                 pdf   NA          pdf        TRUE   
#>  4 application/rtf                 rtf   NA          rtf        TRUE   
#>  5 application/vnd.google-apps.au… NA    NA          audio      NA     
#>  6 application/vnd.google-apps.do… NA    Google Docs document   NA     
#>  7 application/vnd.google-apps.dr… NA    Google Dra… drawing    NA     
#>  8 application/vnd.google-apps.dr… NA    Third-part… drive-sdk  NA     
#>  9 application/vnd.google-apps.fi… NA    Google Dri… file       NA     
#> 10 application/vnd.google-apps.fo… NA    Google Dri… folder     NA     
#> # ℹ 79 more rows
```
