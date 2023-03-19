test_that("drive_auth_configure works", {
  old_client <- drive_oauth_client()
  old_api_key <- drive_api_key()
  withr::defer(
    drive_auth_configure(client = old_client, api_key = old_api_key)
  )

  expect_error_free(drive_oauth_client())
  expect_error_free(drive_api_key())

  expect_snapshot(
    drive_auth_configure(client = gargle::gargle_client(), path = "PATH"),
    error = TRUE
  )

  drive_auth_configure(client = gargle::gargle_client())
  expect_s3_class(drive_oauth_client(), "gargle_oauth_client")

  drive_auth_configure(path = test_path("test-files/client_secret_123.googleusercontent.com.json"))
  expect_s3_class(drive_oauth_client(), "gargle_oauth_client")

  drive_auth_configure(client = NULL)
  expect_null(drive_oauth_client())

  drive_auth_configure(api_key = "API_KEY")
  expect_identical(drive_api_key(), "API_KEY")

  drive_auth_configure(api_key = NULL)
  expect_null(drive_api_key())
})
