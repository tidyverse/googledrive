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
  expect_snapshot(drive_auth_configure(path = 1), error = TRUE)
  expect_snapshot(drive_auth_configure(api_key = 1), error = TRUE)
  expect_snapshot(drive_auth_configure(client = "a"), error = TRUE)

  drive_auth_configure(client = gargle::gargle_client())
  expect_s3_class(drive_oauth_client(), "gargle_oauth_client")

  drive_auth_configure(
    path = system.file(
      "extdata",
      "client_secret_installed.googleusercontent.com.json",
      package = "gargle"
    )
  )
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

# drive_token_write() / drive_token_read() ----
fake_token <- function() {
  httr::Token2.0$new(
    app = httr::oauth_app("fake", key = "KEY", secret = "SECRET"),
    endpoint = httr::oauth_endpoints("google"),
    credentials = list(access_token = "ACCESS", refresh_token = "REFRESH"),
    params = list(scope = "https://www.googleapis.com/auth/drive"),
    cache_path = FALSE
  )
}

test_that("drive_token_write() and drive_token_read() round trip (built-in key)", {
  tok <- fake_token()
  path <- withr::local_tempfile(fileext = ".rds")

  drive_token_write(tok, path = path)
  expect_true(file.exists(path))
  # obfuscated, i.e. not readable as a plain rds
  expect_error(readRDS(path))

  tok2 <- drive_token_read(path)
  expect_s3_class(tok2, "Token2.0")
  expect_identical(tok2$credentials, tok$credentials)
})

test_that("drive_token_write() and drive_token_read() round trip (user key)", {
  withr::local_envvar(GOOGLEDRIVE_TOKEN_TEST_KEY = gargle::secret_make_key())
  tok <- fake_token()
  path <- withr::local_tempfile(fileext = ".rds")

  drive_token_write(tok, path = path, key = "GOOGLEDRIVE_TOKEN_TEST_KEY")
  tok2 <- drive_token_read(path, key = "GOOGLEDRIVE_TOKEN_TEST_KEY")
  expect_identical(tok2$credentials, tok$credentials)

  # the built-in key can't decrypt it
  expect_error(drive_token_read(path))
})

test_that("drive_token_write() accepts the result of drive_token()", {
  tok <- fake_token()
  path <- withr::local_tempfile(fileext = ".rds")
  drive_token_write(httr::config(token = tok), path = path)
  expect_identical(drive_token_read(path)$credentials, tok$credentials)
})

test_that("drive_token_write() and drive_token_read() check inputs", {
  expect_snapshot(drive_token_write("nope", path = "x.rds"), error = TRUE)
  expect_snapshot(
    drive_token_read(path = "does-not-exist.rds"),
    error = TRUE
  )
})
