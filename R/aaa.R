# environment to hold data about the Drive API
.drive <- new.env(parent = emptyenv())

.drive$translate_mime_types <-
  system.file("extdata", "translate_mime_types.csv", package = "googledrive") %>%
  read.csv(stringsAsFactors = FALSE) %>%
  tibble::as_tibble()

.drive$mime_tbl <-
  system.file("extdata", "mime_tbl.csv", package = "googledrive") %>%
  read.csv(stringsAsFactors = FALSE) %>%
  tibble::as_tibble()

.drive$files_fields <-
  system.file("extdata", "files_fields.csv", package = "googledrive") %>%
  read.csv(stringsAsFactors = FALSE) %>%
  tibble::as_tibble()
