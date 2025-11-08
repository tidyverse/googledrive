# An expose object

`expose()` returns a sentinel object, similar in spirit to `NULL`, that
tells the calling function to return its internal data structure.
googledrive stores a lot of information about the Drive API, MIME types,
etc., internally and then exploits it in helper functions, like
[`drive_mime_type()`](https://googledrive.tidyverse.org/dev/reference/drive_mime_type.md),
[`drive_fields()`](https://googledrive.tidyverse.org/dev/reference/drive_fields.md),
[`drive_endpoints()`](https://googledrive.tidyverse.org/dev/reference/drive_endpoints.md),
etc. We use these objects to provide nice defaults, check input
validity, or lookup something cryptic, like MIME type, based on
something friendlier, like a file extension. Pass `expose()` to such a
function if you want to inspect its internal object, in its full glory.
This is inspired by the `waiver()` object in ggplot2.

## Usage

``` r
expose()
```

## Examples

``` r
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
drive_fields(expose())
#> # A tibble: 64 × 2
#>    name                         desc                                   
#>    <chr>                        <chr>                                  
#>  1 appProperties                "A collection of arbitrary key-value p…
#>  2 capabilities                 "Output only. Capabilities the current…
#>  3 contentHints                 "Additional information about the cont…
#>  4 contentRestrictions          "Restrictions for accessing the conten…
#>  5 copyRequiresWriterPermission "Whether the options to copy, print, o…
#>  6 createdTime                  "The time at which the file was create…
#>  7 description                  "A short description of the file."     
#>  8 downloadRestrictions         "Download restrictions applied on the …
#>  9 driveId                      "Output only. ID of the shared drive t…
#> 10 explicitlyTrashed            "Output only. Whether the file has bee…
#> # ℹ 54 more rows
```
