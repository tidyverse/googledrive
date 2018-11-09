## inlining a function in dev version of testthat
## https://github.com/r-lib/testthat/commit/be8e6b6ae87642c157c5ed6510076ba37e1bc0ed
skip_if_offline <- function(host = "r-project.org") {
  skip_if_not_installed("curl")
  has_internet <- !is.null(curl::nslookup(host, error = FALSE))
  if (!has_internet) {
    skip("offline")
  }
}

has_token <- function() {
  env_var <- as.logical(Sys.getenv("GOOGLEDRIVE_LOAD_TOKEN", NA_character_))
  if (isFALSE(env_var)) {
    message("Not attempting to load token")
    return(FALSE)
  }

  token <- tryCatch({
    token_path <- file.path("~/.R/gargle/googledrive-testing.json")
    drive_auth(path = token_path)
    TRUE
  }
  ,
  warning = function(x) FALSE,
  error = function(e) FALSE
  )
  if (!token) {
    message("Unable to load token")
  }

  token
}

skip_if_no_token <- (function() {
  has_token <- NULL
  function() {
    has_token <<- has_token %||% has_token()
    testthat::skip_if_not(has_token, "No Drive token")
  }
})()

nm_fun <- function(context, user = Sys.info()["user"]) {
  y <- purrr::compact(list(context, user))
  function(x) as.character(glue_collapse(c(x, y), sep = "-"))
}
