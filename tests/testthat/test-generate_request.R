context("Generate requests")

test_that("generate_request() basically works", {
  req <- generate_request(endpoint = "drive.files.list", token = NULL)
  expect_type(req, "list")
  expect_identical(
    names(req),
    c("method", "path", "query", "body", "token", "url")
  )
})

test_that("generate_request() messages for incorrect inputs", {
  params <- list(chicken = "muffin", bunny = "pippin")
  expect_message(
    generate_request(endpoint = "drive.files.list",
                     params = params, token = NULL),
    "Ignoring these unrecognized parameters:\nchicken: muffin\nbunny: pippin"
  )
})

test_that("generate_request() handles a mix of correct/incorrect input", {
  params <- list(chicken = "muffin", q = "fields='files/id'")
  expect_message(
    req <- generate_request(endpoint = "drive.files.list",
                            params = params, token = NULL),
    "Ignoring these unrecognized parameters:\nchicken: muffin"
  )
  expect_identical(req[["query"]][["q"]], "fields='files/id'")
})

test_that("generate_request() catches input valid for another endpoint", {
  params <- list(q = "abc", fileId = "def")
  expect_message(
    generate_request(
      endpoint = "drive.permissions.list",
      params = params,
      token = NULL),
    "Ignoring these unrecognized parameters:\nq: abc"
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
    list(fileId = "abc"),
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
  expect_match(req$url, paste0(drive_api_key(), "$"))
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
