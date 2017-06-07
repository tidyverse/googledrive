context("Delete files")

test_that("drive_delete() when there are no matching files", {
  skip_on_appveyor()
  skip_on_travis()

  expect_identical(
    drive_delete("non-existent-file-name", verbose = FALSE),
    logical(0)
  )
})
