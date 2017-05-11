test_that("build_drive_upload behaves", {

  #the file should be a file that exists
  file = "this should not work"
  expect_error(build_drive_upload(file = file, token = NULL, internet = FALSE),sprintf("'%s' does not exist!", file))
})
