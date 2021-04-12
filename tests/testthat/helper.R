has_internet <- !is.null(curl::nslookup(host = "r-project.org", error = FALSE))
if (has_internet && gargle:::secret_can_decrypt("googledrive")) {
  json <- gargle:::secret_read("googledrive", "googledrive-testing.json")
  drive_auth(path = rawToChar(json))
  #drive_empty_trash()
}

skip_if_no_token <- function() {
  testthat::skip_if_not(drive_has_token(), "No Drive token")
}

with_mock <- function(..., .parent = parent.frame()) {
  mockr::with_mock(..., .parent = .parent, .env = "googledrive")
}

nm_fun <- function(context, user = Sys.info()["user"]) {
  y <- purrr::compact(list(context, user))
  function(x) as.character(glue::glue_collapse(c(x, y), sep = "-"))
}

expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

# usage:
# test_file("something.rds")
test_file <- function(name) testthat::test_path("test-files", name)
