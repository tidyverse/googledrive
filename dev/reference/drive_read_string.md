# Read the content of a Drive file

These functions return the content of a Drive file as either a string or
raw bytes. You will likely need to do additional work to parse the
content into a useful R object.

[`drive_download()`](https://googledrive.tidyverse.org/dev/reference/drive_download.md)
is the more generally useful function, but for certain file types, such
as comma-separated values (MIME type `text/csv`), it can be handy to
read data directly from Google Drive and avoid writing to disk.

Just as for
[`drive_download()`](https://googledrive.tidyverse.org/dev/reference/drive_download.md),
native Google file types, such as Google Sheets or Docs, must be
exported as a conventional MIME type. See the help for
[`drive_download()`](https://googledrive.tidyverse.org/dev/reference/drive_download.md)
for more.

## Usage

``` r
drive_read_string(file, type = NULL, encoding = NULL)

drive_read_raw(file, type = NULL)
```

## Arguments

- file:

  Something that identifies the file of interest on your Google Drive.
  Can be a name or path, a file id or URL marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

- type:

  Character. Only consulted if `file` is a native Google file. Specifies
  the desired type of the exported file. Will be processed via
  [`drive_mime_type()`](https://googledrive.tidyverse.org/dev/reference/drive_mime_type.md),
  so either a file extension like `"pdf"` or a full MIME type like
  `"application/pdf"` is acceptable.

- encoding:

  Passed along to
  [`httr::content()`](https://httr.r-lib.org/reference/content.html).
  Describes the encoding of the *input* `file`.

## Value

- `read_drive_string()`: a UTF-8 encoded string

- `read_drive_raw()`: a [`raw()`](https://rdrr.io/r/base/raw.html)
  vector

## Examples

``` r
# comma-separated values --> data.frame or tibble
(chicken_csv <- drive_example_remote("chicken.csv"))
#> # A dribble: 1 × 3
#>   name        id                                drive_resource   
#>   <chr>       <drv_id>                          <list>           
#> 1 chicken.csv 1VOh6wWbRfuQLxbLg87o58vxJt95SIiZ7 <named list [39]>
read.csv(text = chicken_csv |> drive_read_string())
#> No encoding supplied: defaulting to UTF-8.
#>                   chicken            breed     sex
#> 1         Foghorn Leghorn          Leghorn rooster
#> 2          Chicken Little          unknown     hen
#> 3                  Ginger Rhode Island Red     hen
#> 4     Camilla the Chicken       Chantecler     hen
#> 5 Ernie The Giant Chicken           Brahma rooster
#>                                                      motto
#> 1               That's a joke, ah say, that's a joke, son.
#> 2                                      The sky is falling!
#> 3 Listen. We'll either die free chickens or we die trying.
#> 4                                     Bawk, buck, ba-gawk.
#> 5                      Put Captain Solo in the cargo hold.

# Google Doc --> character vector
(chicken_doc <- drive_example_remote("chicken_doc"))
#> # A dribble: 1 × 3
#>   name        id       drive_resource   
#>   <chr>       <drv_id> <list>           
#> 1 chicken_doc 1X9pd4n… <named list [32]>
chicken_doc |>
  # NOTE: we must specify an export MIME type
  drive_read_string(type = "text/plain") |>
  strsplit(split = "(\r\n|\r|\n)")
#> No encoding supplied: defaulting to UTF-8.
#> [[1]]
#> [1] "A chicken whose name was Chantecler"      
#> [2] "Clucked in iambic pentameter"             
#> [3] "It sat on a shelf, reading Song of Myself"
#> [4] "And laid eggs with a perfect diameter."   
#> [5] ""                                         
#> [6] ""                                         
#> [7] "—Richard Maxson"                          
#> 
  (\(x) x[[1]])()
#> Error in (function(x) x[[1]])(): argument "x" is missing, with no default
```
