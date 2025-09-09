# environment to hold data about the Drive API
.drive <- new.env(parent = emptyenv())

.drive$translate_mime_types <-
  system.file(
    "extdata",
    "data",
    "translate_mime_types.csv",
    package = "googledrive",
    mustWork = TRUE
  ) |>
  utils::read.csv(stringsAsFactors = FALSE) |>
  as_tibble()

.drive$mime_tbl <-
  system.file(
    "extdata",
    "data",
    "mime_tbl.csv",
    package = "googledrive",
    mustWork = TRUE
  ) |>
  utils::read.csv(stringsAsFactors = FALSE) |>
  as_tibble()

.drive$files_fields <-
  system.file(
    "extdata",
    "data",
    "files_fields.csv",
    package = "googledrive",
    mustWork = TRUE
  ) |>
  utils::read.csv(stringsAsFactors = FALSE) |>
  as_tibble()

# environment to hold other data that is convenient to cache
.googledrive <- new.env(parent = emptyenv())
