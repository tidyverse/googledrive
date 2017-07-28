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
    if (offline) skip("Offline")
  }
})()

skip_if_no_token <- (function() {
  no_token <- NA
  function() {
    if (is.na(no_token)) {
      env_var <- as.logical(Sys.getenv("GOOGLEDRIVE_LOAD_TOKEN", NA_character_))
      if (isFALSE(env_var)) {
        no_token <<- TRUE
        message("Not attempting to load token")
      } else {
        token <- tryCatch(
          drive_auth(rprojroot::find_testthat_root_file("testing-token.rds")),
          error = function(e) FALSE
        )
        no_token <<- isFALSE(token)
        if (no_token) {
          message("Unable to load token")
        }
      }
    }
    if (no_token) skip("No Drive token")
  }
})()

## call it once here, so message re: token is not muffled by test_that()
tryCatch(skip_if_no_token(), skip = function(x) NULL)

nm_fun <- function(slug, user = Sys.info()["user"]) {
  y <- purrr::compact(list(slug, user))
  function(x) as.character(glue::collapse(c(x, y), sep = "-"))
}
