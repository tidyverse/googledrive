context("Generate requests")

# ---- tests ----
test_that("request_generate() basically works", {
  req <- request_generate(endpoint = "drive.files.list", token = NULL)
  expect_type(req, "list")
  expect_setequal(
    names(req),
    c("method", "url", "body", "token")
  )
  expect_match(req$url, "supportsAllDrives=TRUE")
})

test_that("request_generate() errors for unrecognized parameters", {
  params <- list(chicken = "muffin", bunny = "pippin")
  expect_error(
    request_generate(
      endpoint = "drive.files.list",
      params = params, token = NULL
    ),
    regexp = "These parameters are unknown",
    class = "gargle_error_bad_params"
  )
})

test_that("request_generate() and request_build() can deliver same result", {
  ## include a dummy token to prevent earnest efforts to find an API key
  gen <- request_generate(
    "drive.files.get",
    params = list(fileId = "abc"),
    token = httr::config(token = "token!")
  )
  build <- gargle::request_build(
    path = "drive/v3/files/{fileId}",
    method = "GET",
    params = list(fileId = "abc", supportsAllDrives = TRUE),
    token = httr::config(token = "token!")
  )
  # don't fail for this difference: body is empty list vs empty named list
  expect_identical(purrr::compact(gen), purrr::compact(build))
})

test_that("request_generate() suppresses API key if token is non-NULL", {
  req <- request_generate(
    "drive.files.get",
    params = list(fileId = "abc", key = "key in params"),
    key = "explicit key",
    token = httr::config(token = "token!")
  )
  expect_false(grepl("key", req$url))
})

test_that("request_generate() adds gargle's tidyverse API key if no token", {
  req <- request_generate(
    "drive.files.get",
    params = list(fileId = "abc"),
    token = NULL
  )
  expect_match(req$url, gargle::tidyverse_api_key())
})

test_that("request_generate(): explicit API key > key in params > built-in", {
  req <- request_generate(
    "drive.files.get",
    params = list(fileId = "abc"),
    key = "xyz",
    token = NULL
  )
  expect_match(req$url, "key=xyz")

  req <- request_generate(
    "drive.files.get",
    params = list(fileId = "abc", key = "def"),
    key = "xyz",
    token = NULL
  )
  expect_match(req$url, "key=xyz")

  req <- request_generate(
    "drive.files.get",
    params = list(fileId = "abc", key = "xyz"),
    token = NULL
  )
  expect_match(req$url, "xyz")
})
