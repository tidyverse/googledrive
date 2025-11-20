# Coerce to a `dribble`

Converts various representations of Google Drive files into a
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
the object used by googledrive to hold Drive file metadata. Files can be
specified via:

- File path. File name is an important special case.

- File id. Mark with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md)
  to distinguish from file path.

- Data frame or
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).
  Once you've successfully used googledrive to identify the files of
  interest, you'll have a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).
  Pass it into downstream functions.

- List representing [Files
  resource](https://developers.google.com/drive/api/v3/reference/files)
  objects. Mostly for internal use.

This is a generic function.

For maximum clarity, get your files into a
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
(or capture file id) as early as possible. When specifying via path,
it's best to include the trailing slash when you're targeting a folder.
If you want the folder `foo`, say `foo/`, not `foo`.

Some functions, such as
[`drive_cp()`](https://googledrive.tidyverse.org/dev/reference/drive_cp.md),
[`drive_mkdir()`](https://googledrive.tidyverse.org/dev/reference/drive_mkdir.md),
[`drive_mv()`](https://googledrive.tidyverse.org/dev/reference/drive_mv.md),
and
[`drive_upload()`](https://googledrive.tidyverse.org/dev/reference/drive_upload.md),
can accept the new file or folder name as the last part of `path`, when
`name` is not given. But if you say `a/b/c` (no trailing slash) and a
folder `a/b/c/` already exists, it's unclear what you want. A file named
`c` in `a/b/` or a file with default name in `a/b/c/`? You get an error
and must make your intent clear.

## Usage

``` r
as_dribble(x, ...)
```

## Arguments

- x:

  A vector of Drive file paths, a vector of file ids marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  a list of Files Resource objects, or a suitable data frame.

- ...:

  Other arguments passed down to methods. (Not used.)

## Examples

``` r
# create some files for us to re-discover by name or filepath
alfa <- drive_create("alfa", type = "folder")
#> Created Drive file:
#> • alfa <id: 1gR66-hjwOlnY0aVZAk_24HE4eEGe0I-S>
#> With MIME type:
#> • application/vnd.google-apps.folder
bravo <- drive_create("bravo", path = alfa)
#> Created Drive file:
#> • bravo <id: 1jJ4jLQPMFfQd1x7s14mYb2Ha2wpSsPpw>
#> With MIME type:
#> • application/octet-stream

# as_dribble() can work with file names or paths
as_dribble("alfa")
#> # A dribble: 1 × 4
#>   name  path  id                                drive_resource   
#>   <chr> <chr> <drv_id>                          <list>           
#> 1 alfa  alfa/ 1gR66-hjwOlnY0aVZAk_24HE4eEGe0I-S <named list [35]>
as_dribble("bravo")
#> # A dribble: 2 × 4
#>   name  path  id                                drive_resource   
#>   <chr> <chr> <drv_id>                          <list>           
#> 1 bravo bravo 1jJ4jLQPMFfQd1x7s14mYb2Ha2wpSsPpw <named list [41]>
#> 2 bravo bravo 1Lbnr5CXFtJocrr-u3MIRBO8zbkvkUfXJ <named list [41]>
as_dribble("alfa/bravo")
#> # A dribble: 1 × 4
#>   name  path         id                                drive_resource
#>   <chr> <chr>        <drv_id>                          <list>        
#> 1 bravo ~/alfa/bravo 1jJ4jLQPMFfQd1x7s14mYb2Ha2wpSsPpw <named list>  
as_dribble(c("alfa", "alfa/bravo"))
#> # A dribble: 2 × 4
#>   name  path         id                                drive_resource
#>   <chr> <chr>        <drv_id>                          <list>        
#> 1 alfa  ~/alfa/      1gR66-hjwOlnY0aVZAk_24HE4eEGe0I-S <named list>  
#> 2 bravo ~/alfa/bravo 1jJ4jLQPMFfQd1x7s14mYb2Ha2wpSsPpw <named list>  

# specify the file id (substitute a real file id of your own!)
# as_dribble(as_id("0B0Gh-SuuA2nTOGZVTXZTREgwZ2M"))

# Clean up
drive_find("alfa") |> drive_rm()
#> File deleted:
#> • alfa <id: 1gR66-hjwOlnY0aVZAk_24HE4eEGe0I-S>
```
