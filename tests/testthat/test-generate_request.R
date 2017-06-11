context("Generate requests")

test_that("generate_request() basically works", {

  req <- generate_request(endpoint = "drive.files.list", token = NULL)
  expect_type(req, "list")
  expect_length(req, 7)
  expect_identical(req$method, "GET")
  expect_identical(req$url, "https://www.googleapis.com/drive/v3/files")

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
  expect_identical(req$query, list(q = "fields='files/id'"))
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

test_that("generate_request() catches illegal parameter replication", {
  params <- list(fileId = "abc", fileId = "def")
  expect_error(
    generate_request(
      endpoint = "drive.files.get",
      params = params, token = NULL),
    "These parameter\\(s\\) are not allowed to appear more than once"
  )
})

test_that("generate_request() and build_request() can deliver same result", {
  gen <- generate_request("drive.files.get", list(fileId = "abc"), token = NULL)
  build <- build_request(
    path = "drive/v3/files/{fileId}",
    method = "GET",
    list(fileId = "abc"),
    token = NULL
  )
  expect_identical(gen, build)
})
