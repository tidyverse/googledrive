CLEAN <- SETUP <- FALSE

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
      } else {
        token <- tryCatch(
          drive_auth(rprojroot::find_testthat_root_file("testing-token.rds")),
          error = function(e) FALSE
        )
        no_token <<- isFALSE(token)
      }
    }
    if (no_token) skip("No Drive token")
  }
})()

nm_fun <- function(slug) {
  function(x) paste(paste0(x, slug), collapse = "/")
}
