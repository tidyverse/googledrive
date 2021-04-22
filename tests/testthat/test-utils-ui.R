test_that("warn_for_verbose() does nothing for `verbose = TRUE`", {
  expect_warning(warn_for_verbose(TRUE), NA)
})

test_that("warn_for_verbose() warns for `verbose = FALSE` w/ good message", {
  drive_something <- function() {
    withr::local_options(lifecycle_verbosity = "warning")
    warn_for_verbose(FALSE)
  }
  expect_snapshot(
    drive_something()
  )
})

test_that("warn_for_verbose(FALSE) makes googledrive quiet, in scope", {
  withr::local_options(lifecycle_verbosity = "quiet")
  local_drive_loud_and_wide()
  drive_something <- function() {
    warn_for_verbose(verbose = FALSE)
    message_glue("this message should not be emitted")
  }

  expect_snapshot({
    message_glue("chatty before")
    drive_something()
    message_glue("chatty after")
  })
})
