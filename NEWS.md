# googledrive 0.1.3

Minor patch release for compatibility with the imminent release of purrr 0.3.0.

# googledrive 0.1.2

* Internal usage of `glue::collapse()` modified to call `glue::glue_collapse()` if glue v1.3.0 or later is installed and `glue::collapse()` otherwise. Eliminates a deprecation warning emanating from glue. (#222 @jimhester)

# googledrive 0.1.1

* initial CRAN release
