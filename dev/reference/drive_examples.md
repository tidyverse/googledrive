# Example files

googledrive makes a variety of example files – both local and remote –
available for use in examples and reprexes. These functions help you
access the example files. See
`vignette("example-files", package = "googledrive")` for more.

## Usage

``` r
drive_examples_local(matches)

drive_examples_remote(matches)

drive_example_local(matches)

drive_example_remote(matches)
```

## Arguments

- matches:

  A regular expression that matches the name of the desired example
  file(s). This argument is optional for the plural forms
  (`drive_examples_local()` and `drive_examples_remote()`) and, if
  provided, multiple matches are allowed. The single forms
  (`drive_example_local()` and `drive_example_remote()`) require this
  argument and require that there is exactly one match.

## Value

- For `drive_example_local()` and `drive_examples_local()`, one or more
  local filepaths.

- For `drive_example_remote()` and `drive_examples_remote()`, a
  `dribble`.

## Examples

``` r
drive_examples_local() |> basename()
#> [1] "chicken.csv"     "chicken.jpg"     "chicken.pdf"    
#> [4] "chicken.txt"     "imdb_latin1.csv" "markdown.md"    
#> [7] "r_about.html"    "r_logo.jpg"     
drive_examples_local("chicken") |> basename()
#> [1] "chicken.csv" "chicken.jpg" "chicken.pdf" "chicken.txt"
drive_example_local("imdb")
#> [1] "/home/runner/work/_temp/Library/googledrive/extdata/example_files/imdb_latin1.csv"

drive_examples_remote()
#> # A dribble: 9 × 3
#>   name            id       drive_resource   
#>   <chr>           <drv_id> <list>           
#> 1 chicken_doc     1X9pd4n… <named list [32]>
#> 2 chicken_sheet   1SeFXkr… <named list [32]>
#> 3 chicken.csv     1VOh6wW… <named list [39]>
#> 4 chicken.jpg     1b2_Zjz… <named list [41]>
#> 5 chicken.pdf     13OQcAo… <named list [40]>
#> 6 chicken.txt     1wOLeWV… <named list [40]>
#> 7 imdb_latin1.csv 1YJSVa0… <named list [39]>
#> 8 r_about.html    1sfCT0z… <named list [40]>
#> 9 r_logo.jpg      1J4v-iy… <named list [41]>
drive_examples_remote("chicken")
#> # A dribble: 6 × 3
#>   name          id       drive_resource   
#>   <chr>         <drv_id> <list>           
#> 1 chicken_doc   1X9pd4n… <named list [32]>
#> 2 chicken_sheet 1SeFXkr… <named list [32]>
#> 3 chicken.csv   1VOh6wW… <named list [39]>
#> 4 chicken.jpg   1b2_Zjz… <named list [41]>
#> 5 chicken.pdf   13OQcAo… <named list [40]>
#> 6 chicken.txt   1wOLeWV… <named list [40]>
drive_example_remote("chicken_doc")
#> # A dribble: 1 × 3
#>   name        id       drive_resource   
#>   <chr>       <drv_id> <list>           
#> 1 chicken_doc 1X9pd4n… <named list [32]>
```
