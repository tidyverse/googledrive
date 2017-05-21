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

.drive$params <-
  system.file("extdata", "params.csv", package = "googledrive") %>%
  read.csv(stringsAsFactors = FALSE)

.drive$translate_mime_types <-
  system.file("extdata", "translate_mime_types.csv", package = "googledrive") %>%
  read.csv(stringsAsFactors = FALSE)

.drive$mime_tbl <-
  system.file("extdata", "mime_tbl.csv", package = "googledrive") %>%
  read.csv(stringsAsFactors = FALSE)

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
    googledrive.client_id = "189666615045-8qjpi7iqn5141qbevsnavh08u7brltbq.apps.googleusercontent.com",
    googledrive.client_secret = "9D4iWjMUwLUJDLViBgQQHA3v",
    googledrive.webapp.client_id = "178989665258-mbn7q84ai89if6ja59jmh8tqn5aqoe3n.apps.googleusercontent.com",
    googledrive.webapp.client_secret = "UiF2uCHeMiUH0BeNbSAzzBxL",
    googledrive.webapp.redirect_uri = "http://127.0.0.1:4642"
  )
  toset <- !(names(op.googledrive) %in% names(op))
  if (any(toset)) options(op.googledrive[toset])

  invisible()

}

## from gh

has_names <- function(x){
  n <- names(x)
  if (is.null(n)){
    rep_len(FALSE, length(x))
  } else{
    !(is.na(n) | n == "")
  }
}

has_no_names <- function(x) all(!has_names(x))

clean_names <- function(x){
  if (has_no_names(x)){
    names(x) <- NULL
  }
  x
}

# fx
spf <- function(...) stop(sprintf(...), call. = FALSE)

last <- function(x) x[length(x)]

sq <- function(x) glue::single_quote(x)

crop <- function(x, n = 6L) if (n == 0) x else utils::head(x, -1 * abs(n))

## version of glue::collapse() that returns x if length(x) == 0
collapse2 <- function(x, sep = "", width = Inf, last = "") {
  if (length(x) == 0) {
    x
  } else
    glue::collapse(x = x, sep = sep, width = width, last = last)
}
