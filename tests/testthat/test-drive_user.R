context("Drive user")

test_that("drive_user() reports on the user", {
  skip_if_no_token()
  skip_if_offline()

  user <- drive_user()
  expect_s3_class(user, "drive_user")
  expect_true(all(c("displayName", "emailAddress") %in% names(user)))
})
