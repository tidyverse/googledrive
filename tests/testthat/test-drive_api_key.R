context("API key")

# ---- tests ----
test_that("Explicit API key is passed through", {
  expect_identical(drive_api_key("abc"), "abc")
})

test_that("Env var is consulted, if set", {
  tryCatch(
    {
      Sys.setenv(GOOGLEDRIVE_API_KEY = "abc")
      expect_identical(drive_api_key(), "abc")
    },
    finally = Sys.unsetenv("GOOGLEDRIVE_API_KEY")
  )
  expect_identical(Sys.getenv("GOOGLEDRIVE_API_KEY"), "")
})

test_that("Built-in key is the default", {
  expect_identical(drive_api_key(), getOption("googledrive.api_key"))
})
