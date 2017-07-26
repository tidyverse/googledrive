offline <- function() {
  ping_res <- tryCatch(
    pingr::ping_port("google.com", count = 1, timeout = 0.2),
    error = function(e) NA
  )
  is.na(ping_res)
}
OFFLINE <- offline()
skip_if_offline <- function() if (OFFLINE) skip("Offline")
if (OFFLINE) {
  message("We are OFFLINE.")
}

## how to create the testing token:
##   1. obtain a new, non-caching token via browser flow
##     token <- drive_auth(cache = FALSE)
##   2. double-check the user associated with the token is what you want
##     drive_user()
##   3. write this token to file
##     saveRDS(token, rprojroot::find_testthat_root_file("testing-token.rds"))
##
## Note: the tests will require setup and there will be file/folder creation and
## deletion. Out intent is certainly to not clobber any outside files, but if we
## screw up, it is possible. Likewise, our intent is that the 'clean' procedure
## removes all testing files/folders, but it's possible something gets left
## behind.
if (OFFLINE ||
    identical(Sys.getenv("APPVEYOR"), "True") ||
    identical(Sys.getenv("TRAVIS"), "true")) {
  message("No token available for testing")
} else {
  drive_auth(rprojroot::find_testthat_root_file("testing-token.rds"))
}

nm_fun <- function(slug) {
  function(x) paste(paste0(x, slug), collapse = "/")
}
