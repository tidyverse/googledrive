auth_success <- tryCatch(
  drive_auth_testing(),
  googledrive_auth_internal_error = function(e) NULL
)
if (!isTRUE(auth_success)) {
  drive_bullets(c(
    "!" = "Internal auth failed; calling {.fun drive_deauth}."
  ))
  drive_deauth()
}

skip_if_no_token <- function() {
  testthat::skip_if_not(drive_has_token(), "No Drive token")
}

# usage:
# test_fixture("something.rds")
test_fixture <- function(name) testthat::test_path("test-fixtures", name)

defer_drive_rm <- function(..., env = parent.frame()) {
  withr::defer(
    with_drive_quiet(drive_rm(...)),
    envir = env
  )
}

# used to replace volatile filepaths and file ids in snapshot tests
# may eventually be unnecessary, depending on how this works out:
# https://github.com/r-lib/testthat/issues/1345
# @param replace_me Should be a bare symbol that holds a fixed string
scrub_filepath <- function(message, replace_me) {
  x <- ensym(replace_me)
  gsub(replace_me, paste0("{", as_string(x), "}"), message, fixed = TRUE)
}

scrub_file_id <- function(message) {
  gsub("<id: [a-zA-Z0-9_-]+>", "<id: {FILE_ID}>", message, perl = TRUE)
}

expect_dribble <- function(x) {
  expect_s3_class(x, "dribble")
}

expect_bare_tibble <- function(x) {
  expect_s3_class(x, c("tbl_df", "tbl", "data.frame"), exact = TRUE)
}
