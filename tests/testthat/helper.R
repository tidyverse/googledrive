if (gargle:::secret_can_decrypt("googledrive") &&
    !is.null(curl::nslookup("drive.googleapis.com", error = FALSE))) {
  drive_auth_testing()
} else {
  drive_deauth()
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

defer_drive_rm <- function(..., env = parent.frame()) {
  withr::defer(
    with_drive_quiet(drive_rm(...)),
    envir = env
  )
}

# used to replace volatile filepaths and file ids in snapshot tests
# may eventually be unnecessary, depending on how this works out:
# https://github.com/r-lib/testthat/issues/1345
# @param replace_me Should be a bare symbol
scrub_filepath <- function(message, replace_me) {
  x <- ensym(replace_me)
  gsub(replace_me, paste0("{", as_string(x), "}"), message, perl = TRUE)
}

scrub_file_id <- function(message) {
  gsub("<id: [a-zA-Z0-9_-]+>", "<id: {FILE_ID}>", message, perl = TRUE)
}
