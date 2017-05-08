

test_that("build_gd_ls outputs a list", {
  expect_success(expect_is(build_gd_ls(token = NULL), "list"))
  expect_success(expect_length(build_gd_ls(token = NULL), 10))

  #parameters passed should end up in query
  request <- build_gd_ls(token = NULL, pageSize = 200)
  expect_success(expect_equal(request$query$pageSize, 200))
  expect_success(expect_null(request$params))

})
