test_that("drive_auth_configure works", {
  old_client <- drive_oauth_client()
  old_api_key <- drive_api_key()
  withr::defer(
    drive_auth_configure(client = old_client, api_key = old_api_key)
  )

  expect_no_error(drive_oauth_client())
  expect_no_error(drive_api_key())

  expect_snapshot(
    drive_auth_configure(client = gargle::gargle_client(), path = "PATH"),
    error = TRUE
  )

  drive_auth_configure(client = gargle::gargle_client())
  expect_s3_class(drive_oauth_client(), "gargle_oauth_client")

  drive_auth_configure(path = system.file(
    "extdata", "client_secret_installed.googleusercontent.com.json",
    package = "gargle"
  ))
  expect_s3_class(drive_oauth_client(), "gargle_oauth_client")

  drive_auth_configure(client = NULL)
  expect_null(drive_oauth_client())

  drive_auth_configure(api_key = "API_KEY")
  expect_identical(drive_api_key(), "API_KEY")

  drive_auth_configure(api_key = NULL)
  expect_null(drive_api_key())
})

# drive_scopes() ----
test_that("drive_scopes() reveals Drive scopes", {
  expect_snapshot(drive_scopes())
})

test_that("drive_scopes() substitutes actual scope for short form", {
  expect_equal(
    drive_scopes(c(
      "full",
      "drive",
      "drive.readonly"
    )),
    c(
      "https://www.googleapis.com/auth/drive",
      "https://www.googleapis.com/auth/drive",
      "https://www.googleapis.com/auth/drive.readonly"
    )
  )
})

test_that("drive_scopes() passes unrecognized scopes through", {
  expect_equal(
    drive_scopes(c(
      "email",
      "drive.metadata.readonly",
      "https://www.googleapis.com/auth/cloud-platform"
    )),
    c(
      "email",
      "https://www.googleapis.com/auth/drive.metadata.readonly",
      "https://www.googleapis.com/auth/cloud-platform"
    )
  )
})
