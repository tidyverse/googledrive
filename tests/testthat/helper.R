offline <- function() {
  ping_res <- tryCatch(
    pingr::ping_port("google.com", count = 1, timeout = 0.2),
    error = function(e) NA
  )
  is.na(ping_res)
}
OFFLINE <- offline()
skip_if_offline <- function() if (OFFLINE) skip("Offline")

## in a session and directory where you are willing to authenticate or have
## an existing .httr-oauth, do this:
## token <- drive_auth()
## make sure you are happy with this user running tests!
## folders and files will be created AND DELETED!
## drive_user()
## saveRDS(token, rprojroot::find_testthat_root_file("testing-token.rds"))
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
