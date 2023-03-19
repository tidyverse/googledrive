test_that("drive_auth_config() is deprecated", {
  withr::local_options(lifecycle_verbosity = "warning")
  expect_snapshot(
    error = TRUE,
    drive_auth_config()
  )
  })

test_that("drive_oauth_app() is deprecated", {
  withr::local_options(lifecycle_verbosity = "warning")
  expect_snapshot(absorb <- drive_oauth_app())
})

test_that("drive_auth_configure(app =) is deprecated in favor of client", {
  withr::local_options(lifecycle_verbosity = "warning")
  (original_client <- drive_oauth_client())
  withr::defer(drive_auth_configure(client = original_client))

  client <- gargle::gargle_oauth_client_from_json(
    system.file(
      "extdata", "data", "client_secret_123.googleusercontent.com.json",
      package = "googledrive"
    ),
    name = "test-client"
  )
  expect_snapshot(
    drive_auth_configure(app = client)
  )
  expect_equal(drive_oauth_client()$name, "test-client")
  expect_equal(drive_oauth_client()$id, "abc.apps.googleusercontent.com")
})
