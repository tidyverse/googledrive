
test_that("build_gd_ls behaves properly", {

  # should be a list
  expect_success(expect_is(build_gd_ls(token = NULL), "list"))

  # default with 10 elements
  expect_success(expect_length(build_gd_ls(token = NULL), 10))

  # named
  expect_success(expect_named(build_gd_ls(token = NULL),
                              c("method","url","headers","query","body","endpoint","params","token","send_headers","api_url")))

  #parameters passed should end up in query
  request <- build_gd_ls(token = NULL, pageSize = 200)
  expect_success(expect_equal(request$query$pageSize, 200))
  expect_success(expect_null(request$params))

})
