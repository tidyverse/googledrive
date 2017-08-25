#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom purrr %>%
#' @usage lhs \%>\% rhs
NULL

if (getRversion() >= "2.15.1")  utils::globalVariables(c(":="))

# environment to hold data about the Drive API
.drive <- new.env(parent = emptyenv())
.drive$base_url <- "https://www.googleapis.com"

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

# environment to store credentials
.state <- new.env(parent = emptyenv())
## we will outsource a great deal of this to gargle, but not in time for
## the first CRAN release of googledrive
## https://github.com/r-lib/gargle
## these are the tidyverse-wide values, copied from gargle
.state[["tidyverse_api_key"]] <- "AIzaSyCJ-oYJlNhbPDJySWsbR_B7QqzNz5EthTg"
.state[["tidyverse_app"]] <-
  httr::oauth_app(
    appname = "tidyverse",
    key = "603366585132-nku3fbd298ma3925l12o2hq0cc1v8u11.apps.googleusercontent.com",
    secret = "as_N12yfWLRL9RMz5nVpgCZt"
  )

.onLoad <- function(libname, pkgname) {

  set_auth_active(TRUE)
  set_api_key(.state[["tidyverse_api_key"]])
  set_oauth_app(.state[["tidyverse_app"]])

  if (requireNamespace("dplyr", quietly = TRUE)) {
    register_s3_method("dplyr", "arrange", "dribble")
    register_s3_method("dplyr", "filter", "dribble")
    register_s3_method("dplyr", "mutate", "dribble")
    register_s3_method("dplyr", "rename", "dribble")
    register_s3_method("dplyr", "select", "dribble")
    register_s3_method("dplyr", "slice", "dribble")
  }

  ## I have to use curl directly somewhere, if I import it.
  ## I have to import it if I want to state a minimum version.
  local(curl::curl_version())

  invisible()

}
