context("List files")

nm_ <- nm_fun("-TEST-drive-ls")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del_pths <- c(nm_("foo"), nm_("this-should-not-exist"))
    del <- purrr::map(del_pths, drive_delete, verbose = FALSE)
  }
  ## test that it finds at least a folder
  drive_mkdir(nm_("foo"), verbose = FALSE)
}

test_that("drive_ls() errors if file does not exist", {
  skip_on_appveyor()
  skip_on_travis()

  expect_error(
    drive_ls(nm_("this-should-not-exist")),
    "Input must specify exactly 1 Drive file."
  )
})

test_that("drive_ls() outputs contents of folder", {
  skip_on_appveyor()
  skip_on_travis()

  expect_equivalent(
    drive_ls(nm_("foo")),
    dribble()
  )
})
