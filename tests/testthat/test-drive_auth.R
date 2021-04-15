test_that("drive_auth_configure works", {
  old_app <- drive_oauth_app()
  old_api_key <- drive_api_key()
  withr::defer(
    drive_auth_configure(app = old_app, api_key = old_api_key)
  )

  expect_error_free(drive_oauth_app())
  expect_error_free(drive_api_key())

  expect_snapshot(
    drive_auth_configure(app = gargle::gargle_app(), path = "PATH"),
    error = TRUE
  )

  drive_auth_configure(app = gargle::gargle_app())
  expect_s3_class(drive_oauth_app(), "oauth_app")

  drive_auth_configure(path = test_path("test-files/client_secret_123.googleusercontent.com.json"))
  expect_s3_class(drive_oauth_app(), "oauth_app")

  drive_auth_configure(app = NULL)
  expect_null(drive_oauth_app())

  drive_auth_configure(api_key = "API_KEY")
  expect_identical(drive_api_key(), "API_KEY")

  drive_auth_configure(api_key = NULL)
  expect_null(drive_api_key())
})
