# Request partial resources

You may be able to improve the performance of your API calls by
requesting only the metadata that you actually need. This function is
primarily for internal use and is currently focused on the [Files
resource](https://developers.google.com/drive/api/v3/reference/files).
Note that high-level googledrive functions assume that the `name`, `id`,
and `kind` fields are included, at a bare minimum. Assuming that
`resource = "files"` (the default), input provided via `fields` is
checked for validity against the known field names and the validated
fields are returned. To see a tibble containing all possible fields and
a short description of each, call `drive_fields(expose())`.

`prep_fields()` prepares fields for inclusion as query parameters.

## Usage

``` r
drive_fields(fields = NULL, resource = "files")

prep_fields(fields, resource = "files")
```

## Arguments

- fields:

  Character vector of field names. If `resource = "files"`, they are
  checked for validity. Otherwise, they are passed through.

- resource:

  Character, naming the API resource of interest. Currently, only the
  Files resource is anticipated.

## Value

`drive_fields()`: Character vector of field names. `prep_fields()`: a
string.

## See also

[Improve
performance](https://developers.google.com/drive/api/v3/performance), in
the Drive API documentation.

## Examples

``` r
# get a tibble of all fields for the Files resource + indicator of defaults
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

# invalid fields are removed and throw warning
drive_fields(c("name", "parents", "ownedByMe", "pancakes!"))
#> Warning: Omitting fields that are not recognized as part of the Files resource:
#> • pancakes!
#> [1] "name"      "parents"   "ownedByMe"

# prepare fields for query
prep_fields(c("name", "parents", "kind"))
#> [1] "files/name,files/parents,files/kind"
```
