# Example Files

The googledrive package makes some world-readable, persistent example
files available on Google Drive, to use in examples and reprexes. Local
versions of those same example files also ship with the googledrive
package, to make it easier to demo specific workflows that start with,
e.g.,
[`drive_upload()`](https://googledrive.tidyverse.org/dev/reference/drive_upload.md).

This article lists these assets and explains how to get at them. Since
the remote example files are accessible to all, after we attach
googledrive, we also do
[`drive_deauth()`](https://googledrive.tidyverse.org/dev/reference/drive_deauth.md).

``` r
library(googledrive)

drive_deauth()
```

## Local example files

Call
[`drive_examples_local()`](https://googledrive.tidyverse.org/dev/reference/drive_examples.md)
to get the full filepaths.
[`basename()`](https://rdrr.io/r/base/basename.html) (and
[`fs::path_file()`](https://fs.r-lib.org/reference/path_file.html)) are
handy functions for getting just the filename.

``` r
(x <- drive_examples_local())
#> [1] "/home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.csv"    
#> [2] "/home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.jpg"    
#> [3] "/home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.pdf"    
#> [4] "/home/runner/work/_temp/Library/googledrive/extdata/example_files/chicken.txt"    
#> [5] "/home/runner/work/_temp/Library/googledrive/extdata/example_files/imdb_latin1.csv"
#> [6] "/home/runner/work/_temp/Library/googledrive/extdata/example_files/markdown.md"    
#> [7] "/home/runner/work/_temp/Library/googledrive/extdata/example_files/r_about.html"   
#> [8] "/home/runner/work/_temp/Library/googledrive/extdata/example_files/r_logo.jpg"

basename(x)
#> [1] "chicken.csv"     "chicken.jpg"     "chicken.pdf"    
#> [4] "chicken.txt"     "imdb_latin1.csv" "markdown.md"    
#> [7] "r_about.html"    "r_logo.jpg"
```

You can filter the files by providing a regular expression.

``` r
drive_examples_local("csv") |> basename()
#> [1] "chicken.csv"     "imdb_latin1.csv"
```

If you want exactly one file, use the singular
[`drive_example_local()`](https://googledrive.tidyverse.org/dev/reference/drive_examples.md)
and provide the file’s name (or any sufficiently specific regular
expression):

``` r
drive_examples_local("chicken.jpg") |> basename()
#> [1] "chicken.jpg"

drive_examples_local("imdb") |> basename()
#> [1] "imdb_latin1.csv"
```

Here’s how you might use one of these examples to start demonstrating
something with googledrive:

``` r
new_google_sheet <- drive_examples_local("chicken.csv") |>
  drive_upload(type = "spreadsheet")
# ... example or reprex continues ...
```

## Remote example files

Call
[`drive_examples_remote()`](https://googledrive.tidyverse.org/dev/reference/drive_examples.md)
to get a `dribble` of the remote example files. Here I also reveal their
MIME type.

``` r
drive_examples_remote() |>
  drive_reveal("mime_type")
#> # A dribble: 9 × 4
#>   name            mime_type                     id       drive_resource
#>   <chr>           <chr>                         <drv_id> <list>        
#> 1 chicken_doc     application/vnd.google-apps.… 1X9pd4n… <named list>  
#> 2 chicken_sheet   application/vnd.google-apps.… 1SeFXkr… <named list>  
#> 3 chicken.csv     text/csv                      1VOh6wW… <named list>  
#> 4 chicken.jpg     image/jpeg                    1b2_Zjz… <named list>  
#> 5 chicken.pdf     application/pdf               13OQcAo… <named list>  
#> 6 chicken.txt     text/plain                    1wOLeWV… <named list>  
#> 7 imdb_latin1.csv text/csv                      1YJSVa0… <named list>  
#> 8 r_about.html    text/html                     1sfCT0z… <named list>  
#> 9 r_logo.jpg      image/jpeg                    1J4v-iy… <named list>
```

You’ll notice there are two files that aren’t among the local example
files, but that are derived from them:

- `chicken_doc`: a Google Document made from `chicken.txt`
- `chicken_sheet`: a Google Sheet made from `chicken.csv`

Here’s a clickable table of the remote example files:

| name (these are links)                                                                                                 | id                                            |
|:-----------------------------------------------------------------------------------------------------------------------|:----------------------------------------------|
| [chicken_doc](https://docs.google.com/document/d/1X9pd4nOjl33zDFfTjw-_eFL7Qb9_g6VfVFDp1PPae94/edit?usp=drivesdk)       | 1X9pd4nOjl33zDFfTjw-\_eFL7Qb9_g6VfVFDp1PPae94 |
| [chicken_sheet](https://docs.google.com/spreadsheets/d/1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU/edit?usp=drivesdk) | 1SeFXkr3XdzPSuWauzPdN-XnaryOYmZ7sFiUF5t-wSVU  |
| [chicken.csv](https://drive.google.com/file/d/1VOh6wWbRfuQLxbLg87o58vxJt95SIiZ7/view?usp=drivesdk)                     | 1VOh6wWbRfuQLxbLg87o58vxJt95SIiZ7             |
| [chicken.jpg](https://drive.google.com/file/d/1b2_ZjzgvrSw0hBMgn-rnEbjp3Uq0XTKJ/view?usp=drivesdk)                     | 1b2_ZjzgvrSw0hBMgn-rnEbjp3Uq0XTKJ             |
| [chicken.pdf](https://drive.google.com/file/d/13OQcAo8hkh0Ja5Wxlmi4a8aNvPK7pDkO/view?usp=drivesdk)                     | 13OQcAo8hkh0Ja5Wxlmi4a8aNvPK7pDkO             |
| [chicken.txt](https://drive.google.com/file/d/1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y/view?usp=drivesdk)                     | 1wOLeWVRkTb6lDmLRiOhg9iKM7DlN762Y             |
| [imdb_latin1.csv](https://drive.google.com/file/d/1YJSVa0LTaVtGrZ4eVXYrSQ4y50uFl5bw/view?usp=drivesdk)                 | 1YJSVa0LTaVtGrZ4eVXYrSQ4y50uFl5bw             |
| [r_about.html](https://drive.google.com/file/d/1sfCT0zqDz3vpZZlv_4nFlhq2WMaKqjow/view?usp=drivesdk)                    | 1sfCT0zqDz3vpZZlv_4nFlhq2WMaKqjow             |
| [r_logo.jpg](https://drive.google.com/file/d/1J4v-iyydf1Cad3GjDkGRrynauV9JFOyW/view?usp=drivesdk)                      | 1J4v-iyydf1Cad3GjDkGRrynauV9JFOyW             |

Accessing the remote example files works just like the local files.
Provide a regular expression to specify the name of target file(s). Use
the singular form to target exactly one file.

``` r
drive_examples_remote("chicken")
#> # A dribble: 6 × 3
#>   name          id       drive_resource   
#>   <chr>         <drv_id> <list>           
#> 1 chicken_doc   1X9pd4n… <named list [31]>
#> 2 chicken_sheet 1SeFXkr… <named list [31]>
#> 3 chicken.csv   1VOh6wW… <named list [38]>
#> 4 chicken.jpg   1b2_Zjz… <named list [40]>
#> 5 chicken.pdf   13OQcAo… <named list [39]>
#> 6 chicken.txt   1wOLeWV… <named list [39]>

drive_example_remote("logo")
#> # A dribble: 1 × 3
#>   name       id                                drive_resource   
#>   <chr>      <drv_id>                          <list>           
#> 1 r_logo.jpg 1J4v-iyydf1Cad3GjDkGRrynauV9JFOyW <named list [41]>
```

Here’s how you might use one of these examples to start demonstrating
something with googledrive:

``` r
new_google_doc <- drive_examples_remote("chicken_doc") |>
  drive_cp(name = "I have a chicken problem")
# ... example or reprex continues ...
```
