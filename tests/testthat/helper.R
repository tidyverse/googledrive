CLEAN <- SETUP <- FALSE
isFALSE <- function(x) identical(x, FALSE)

## inspired by developments over in gh
## https://github.com/r-lib/gh/blob/master/tests/testthat/helper-offline.R
skip_if_offline <- (function() {
  offline <- NA
  function() {
    if (is.na(offline)) {
      offline <<- tryCatch(
        is.na(pingr::ping_port("google.com", count = 1, timeout = 1)),
        error = function(e) TRUE
      )
    }
    if (offline) testthat::skip("Offline")
  }
})()

has_token <- function() {
  env_var <- as.logical(Sys.getenv("GOOGLEDRIVE_LOAD_TOKEN", NA_character_))
  if (isFALSE(env_var)) {
    message("Not attempting to load token")
    return(FALSE)
  }

  token <- tryCatch(
    {
      token_path <- file.path("~/.R/gargle/googledrive-testing.json")
      drive_auth(service_token = token_path)
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

## call it once here, so message re: token is not muffled by test_that()
tryCatch(skip_if_no_token(), skip = function(x) NULL)

nm_fun <- function(context, user = Sys.info()["user"]) {
  y <- purrr::compact(list(context, user))
  function(x) as.character(glue_collapse(c(x, y), sep = "-"))
}

message("Test file naming scheme:\n  * ", nm_fun("TEST-context")("foo"))
