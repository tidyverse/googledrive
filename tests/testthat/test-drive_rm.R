context("Delete files")

# ---- tests ----
test_that("drive_rm() when there are no matching files", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  expect_identical(
    drive_rm("non-existent-file-name", verbose = FALSE),
    logical(0)
  )
})
