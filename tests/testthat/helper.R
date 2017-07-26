CLEAN <- SETUP <- FALSE

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
