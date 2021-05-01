test_that("bulletize() works", {
  expect_snapshot(cli::cli_bullets(bulletize(letters)))
  expect_snapshot(cli::cli_bullets(bulletize(letters, bullet = "x")))
  expect_snapshot(cli::cli_bullets(bulletize(letters, n_show = 2)))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:6])))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:7])))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:8])))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:6], n_fudge = 0)))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:8], n_fudge = 3)))
k})

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
    drive_bullets("this message should not be emitted")
  }

  expect_snapshot({
    drive_bullets("chatty before")
    drive_something()
    drive_bullets("chatty after")
  })
})
