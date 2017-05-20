context("Drive path helpers")

test_that("split_path() strips leading ~ or ~/ or /, then splits", {
  expect_identical(split_path(""), character(0))
  expect_identical(split_path("~"), character(0))
  expect_identical(split_path("~/"), character(0))
  expect_identical(split_path("/"), character(0))
  expect_identical(split_path("/abc"), "abc")
  expect_identical(split_path("/abc/"), "abc")
  expect_identical(split_path("/a/bc/"), c("a", "bc"))
  expect_identical(split_path("a/bc"), c("a", "bc"))
  expect_identical(split_path("a/bc/"), c("a", "bc"))
})

test_that("form_query() handles paths w/ all combos of dir and leaf piece(s)", {
  expect_identical(
    ## path = a/b/
    form_query(c("a", "b"), TRUE),
    "((name = 'a' or name = 'b') and mimeType = 'application/vnd.google-apps.folder')"
  )
  expect_identical(
    ## path = a/b
    form_query(c("a", "b"), FALSE),
    "name = 'b' or ((name = 'a') and mimeType = 'application/vnd.google-apps.folder')"
  )
  expect_identical(
    ## path = a/
    form_query("a", TRUE),
    "((name = 'a') and mimeType = 'application/vnd.google-apps.folder')"
  )
  expect_identical(
    ## path = a
    form_query("a", FALSE),
    "name = 'a'"
  )
})
