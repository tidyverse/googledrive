#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom purrr %>%
#' @usage lhs \%>\% rhs
NULL

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

.onLoad <- function(libname, pkgname) {

  op <- options()
  op.googledrive <- list(
    ## httr_oauth_cache can be a path, but I'm only really thinking about and
    ## supporting the simpler TRUE/FALSE usage, i.e. assuming that .httr-oauth
    ## will live in current working directory if it exists at all
    ## this is main reason for creating this googledrive-specific variant
    googledrive.httr_oauth_cache = TRUE,
    ## these are the tidyverse-wide values, copied from gargle
    googledrive.client_id = "603366585132-nku3fbd298ma3925l12o2hq0cc1v8u11.apps.googleusercontent.com",
    googledrive.client_secret = "as_N12yfWLRL9RMz5nVpgCZt",
    googledrive.api_key = "AIzaSyCJ-oYJlNhbPDJySWsbR_B7QqzNz5EthTg",
    ## these are still copied over from googlesheets and not in use
    googledrive.webapp.client_id = "178989665258-mbn7q84ai89if6ja59jmh8tqn5aqoe3n.apps.googleusercontent.com",
    googledrive.webapp.client_secret = "UiF2uCHeMiUH0BeNbSAzzBxL",
    googledrive.webapp.redirect_uri = "http://127.0.0.1:4642"
  )
  toset <- !(names(op.googledrive) %in% names(op))
  if (any(toset)) options(op.googledrive[toset])

  if (requireNamespace("dplyr", quietly = TRUE)) {
    register_s3_method("dplyr", "arrange", "dribble")
    register_s3_method("dplyr", "filter", "dribble")
    register_s3_method("dplyr", "mutate", "dribble")
    register_s3_method("dplyr", "rename", "dribble")
    register_s3_method("dplyr", "select", "dribble")
    register_s3_method("dplyr", "slice", "dribble")
  }

  invisible()

}
