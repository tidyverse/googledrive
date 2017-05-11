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

#this is directly from googlesheets

#environment to store credentials
.state <- new.env(parent = emptyenv())
.state$drive_base_url_files_v3 <- "https://www.googleapis.com/drive/v3/files"
.state$drive_base_url <- "https://www.googleapis.com"

.onLoad <- function(libname, pkgname) {

  op <- options()
  op.googledrive <- list(
    ## httr_oauth_cache can be a path, but I'm only really thinking about and
    ## supporting the simpler TRUE/FALSE usage, i.e. assuming that .httr-oauth
    ## will live in current working directory if it exists at all
    ## this is main reason for creating this googledrive-specific variant
    googledrive.httr_oauth_cache = TRUE,
    googledrive.client_id = "178989665258-f4scmimctv2o96isfppehg1qesrpvjro.apps.googleusercontent.com",
    googledrive.client_secret = "iWPrYg0lFHNQblnRrDbypvJL",
    googledrive.webapp.client_id = "178989665258-mbn7q84ai89if6ja59jmh8tqn5aqoe3n.apps.googleusercontent.com",
    googledrive.webapp.client_secret = "UiF2uCHeMiUH0BeNbSAzzBxL",
    googledrive.webapp.redirect_uri = "http://127.0.0.1:4642"
  )
  toset <- !(names(op.googledrive) %in% names(op))
  if(any(toset)) options(op.googledrive[toset])

  invisible()

}

