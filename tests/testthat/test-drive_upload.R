context("Upload files")

test_that("drive_upload behaves", {
  skip_on_appveyor()
  skip_on_travis()

  #the file should be a file that exists
  input <- "this should not work"
  expect_error(drive_upload(from = input), "File does not exist")
})
