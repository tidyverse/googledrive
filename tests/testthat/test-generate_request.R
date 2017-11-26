context("Generate requests")

# ---- tests ----
test_that("generate_request() basically works", {
  req <- generate_request(endpoint = "drive.files.list", token = NULL)
  expect_type(req, "list")
  expect_identical(
    names(req),
    c("method", "path", "query", "body", "token", "url")
  )
  expect_true(req$query$supportsTeamDrives)
})

test_that("generate_request() errors for unrecognized parameters", {
  params <- list(chicken = "muffin", bunny = "pippin")
  expect_error(
    generate_request(
      endpoint = "drive.files.list",
      params = params, token = NULL
    ),
    "These parameters are not recognized for this endpoint:\nchicken\nbunny"
  )
})

test_that("generate_request() and build_request() can deliver same result", {
  ## include a dummy token to prevent earnest efforts to find an API key
  gen <- generate_request(
    "drive.files.get",
    list(fileId = "abc"),
    token = httr::config(token = "token!")
  )
  build <- build_request(
    path = "drive/v3/files/{fileId}",
    method = "GET",
    params = list(fileId = "abc", supportsTeamDrives = TRUE),
    token = httr::config(token = "token!")
  )
  expect_identical(gen, build)
})

test_that("generate_request() suppresses API key if token is non-NULL", {
  req <- generate_request(
    "drive.files.get",
    params = list(fileId = "abc", key = "key in params"),
    key = "explicit key",
    token = httr::config(token = "token!")
  )
  expect_false(grepl("key", req$url))
})

test_that("generate_request() adds built-in API key when token = NULL", {
  req <- generate_request(
    "drive.files.get",
    params = list(fileId = "abc"),
    token = NULL
  )
  expect_match(req$url, drive_api_key())
})

test_that("generate_request(): explicit API key > key in params > built-in", {
  req <- generate_request(
    "drive.files.get",
    params = list(fileId = "abc"),
    key = "xyz",
    token = NULL
  )
  expect_match(req$url, "key=xyz")

  req <- generate_request(
    "drive.files.get",
    params = list(fileId = "abc", key = "def"),
    key = "xyz",
    token = NULL
  )
  expect_match(req$url, "key=xyz")

  req <- generate_request(
    "drive.files.get",
    params = list(fileId = "abc", key = "xyz"),
    token = NULL
  )
  expect_match(req$url, "xyz")
})
