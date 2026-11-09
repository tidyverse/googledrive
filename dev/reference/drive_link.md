# Retrieve Drive file links

Returns the `"webViewLink"` for one or more files, which is the "link
for opening the file in a relevant Google editor or viewer in a
browser".

## Usage

``` r
drive_link(file)
```

## Arguments

- file:

  Something that identifies the file(s) of interest on your Google
  Drive. Can be a character vector of names/paths, a character vector of
  file ids or URLs marked with
  [`as_id()`](https://googledrive.tidyverse.org/dev/reference/drive_id.md),
  or a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md).

## Value

Character vector of file hyperlinks.

## Examples

``` r
# get a few files into a dribble
three_files <- drive_find(n_max = 3)

# get their browser links
drive_link(three_files)
#> [1] "https://docs.google.com/spreadsheets/d/1s0kEHcqG2PyciERoGq52L_Qwzp4y3__rBVKSx7E_j88/edit?usp=drivesdk"
#> [2] "https://drive.google.com/file/d/1wFAZdmBiSRu4GShsqurxD7wIDSCZvPud/view?usp=drivesdk"                  
#> [3] "https://drive.google.com/file/d/19URV7BT0_E1KhYdfDODszK5aiELOwTSz/view?usp=drivesdk"                  
```
