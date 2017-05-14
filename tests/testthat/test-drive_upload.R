test_that("build_drive_upload behaves", {
  #the file should be a file that exists
  input <- "this should not work"
  expect_error(
    build_drive_upload(
      input = input,
      token = NULL,
      internet = FALSE
    ),
    sprintf("'%s' does not exist!", input)
  )
})
