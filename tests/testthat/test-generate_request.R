context("Generate requests")

# ---- tests ----
test_that("generate_request() basically works", {
  req <- generate_request(endpoint = "drive.files.list", token = NULL)
  expect_type(req, "list")
  expect_identical(
    names(req),
    c("method", "path", "query", "body", "token", "url")
  )
})

test_that("generate_request() errors for unrecognized parameters", {
  params <- list(chicken = "muffin", bunny = "pippin")
  expect_error(
    generate_request(endpoint = "drive.files.list",
                     params = params, token = NULL),
    "These parameters are not recognized for this endpoint:\nchicken\nbunny"
  )
})

test_that("generate_request() and build_request() can deliver same result", {
  gen <- generate_request(
    "drive.files.get",
    list(fileId = "abc"),
    key = NULL,
    token = NULL
  )
  build <- build_request(
    path = "drive/v3/files/{fileId}",
    method = "GET",
    params = list(fileId = "abc", supportsTeamDrives = TRUE),
    token = NULL
  )
  expect_identical(gen, build)
})

test_that("API key is added by default in generate_request()", {
  req <- generate_request(
    "drive.files.get",
    list(fileId = "abc"),
    token = NULL
  )
  expect_match(req$url, drive_api_key())
})

test_that("Explicit key = NULL suppresses API key in generate_request()", {
  req <- generate_request(
    "drive.files.get",
    list(fileId = "abc", key = NULL),
    token = NULL
  )
  expect_false(grepl(drive_api_key(), req$url))
  req <- generate_request(
    "drive.files.get",
    list(fileId = "abc"),
    key = NULL,
    token = NULL
  )
  expect_false(grepl(drive_api_key(), req$url))
})

test_that("key in params of generate_request() overrides key argument", {
  req <- generate_request(
    "drive.files.get",
    list(fileId = "abc", key = "xyz"),
    key = "uvw",
    token = NULL
  )
  expect_match(req$url, "xyz")
  expect_false(grepl("uvw", req$url))

  req <- generate_request(
    "drive.files.get",
    list(fileId = "abc", key = NULL),
    key = "uvw",
    token = NULL
  )
  expect_false(grepl("uvw", req$url))
  expect_false(grepl("uvw", req$url))
})
