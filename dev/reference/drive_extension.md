# Lookup extension from MIME type

This is a helper to determinine which extension should be used for a
file. Two types of input are acceptable:

- MIME types accepted by Google Drive.

- File extensions, such as "pdf", "csv", etc. (these are simply passed
  through).

## Usage

``` r
drive_extension(type = NULL)
```

## Arguments

- type:

  Character. MIME type or file extension.

## Value

Character. File extension.

## Examples

``` r
## get the extension for mime type image/jpeg
drive_extension("image/jpeg")
#> [1] "jpeg"

## it's vectorized
drive_extension(c("text/plain", "pdf", "image/gif"))
#> [1] "txt" "pdf" "gif"
```
