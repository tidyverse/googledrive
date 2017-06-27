context("Path utilities")

test_that("rootize_path() standardizes root", {
  expect_identical(rootize_path("~"), "~/")
  expect_identical(rootize_path("~/"), "~/")
  expect_identical(rootize_path("/"), "~/")
  expect_identical(rootize_path(NULL), NULL)
  expect_identical(rootize_path(""), "")
  expect_identical(rootize_path("~abc"), "~abc")
  expect_identical(rootize_path("~/abc"), "~/abc")
  expect_identical(rootize_path("/abc/"), "~/abc/")
  expect_identical(rootize_path("~/a/bc/"), "~/a/bc/")
  expect_identical(rootize_path("~a/bc"), "~a/bc")
  expect_identical(rootize_path("a"), "a")
  expect_identical(rootize_path("a/bc"), "a/bc")
})

test_that("split_path() splits paths", {
  expect_identical(split_path(""), character(0))
  expect_identical(split_path("~"), "~")
  expect_identical(split_path("~/"), "~")
  expect_identical(split_path("/"), "~")
  expect_identical(split_path("/abc"), c("~", "abc"))
  expect_identical(split_path("/abc/"), c("~", "abc"))
  expect_identical(split_path("/a/bc/"), c("~", "a", "bc"))
  expect_identical(split_path("a/bc"), c("a", "bc"))
  expect_identical(split_path("a/bc/"), c("a", "bc"))
})

test_that("unsplit_path() is file.path(), but never leads with /'s", {
  expect_identical(unsplit_path(), character(0))
  expect_identical(unsplit_path(""), "")
  expect_identical(unsplit_path("", "a"), "a")
  expect_identical(unsplit_path("", "", "a"), "a")
  expect_identical(unsplit_path("a", "b"), file.path("a", "b"))
})

test_that("append_slash() appends a slash or declines to do so", {
  expect_identical(append_slash("a"), "a/")
  expect_identical(append_slash("a/"), "a/")
  expect_identical(append_slash("/"), "/")
  expect_identical(append_slash(""), "")
  expect_identical(append_slash(character(0)), character(0))
})

test_that("strip_slash() strips a trailing slash", {
  expect_identical(strip_slash("a"), "a")
  expect_identical(strip_slash("a/"), "a")
  expect_identical(strip_slash("/"), "")
  expect_identical(strip_slash(""), "")
  expect_identical(strip_slash(character(0)), character(0))
})

test_that("form_query() handles paths w/ all combos of dir and leaf piece(s)", {
  expect_identical(
    ## path = a/b/
    form_query(c("a", "b"), TRUE),
    glue::as_glue("((name = 'a' or name = 'b') and mimeType = 'application/vnd.google-apps.folder')")
  )
  expect_identical(
    ## path = a/b
    form_query(c("a", "b"), FALSE),
    glue::as_glue("name = 'b' or ((name = 'a') and mimeType = 'application/vnd.google-apps.folder')")
  )
  expect_identical(
    ## path = a/
    form_query("a", TRUE),
    glue::as_glue("((name = 'a') and mimeType = 'application/vnd.google-apps.folder')")
  )
  expect_identical(
    ## path = a
    form_query("a", FALSE),
    glue::as_glue("name = 'a'")
  )
})

test_that("is_root() recognizes requests for root folder", {
  expect_true(is_root("~"))
  expect_true(is_root("~/"))
  expect_true(is_root("/"))
  expect_false(is_root(NULL))
  expect_false(is_root(character(0)))
  expect_false(is_root("abc"))
  expect_false(is_root("/abc"))
  expect_false(is_root("~/abc"))
})

test_that("file_ext_safe() returns NULL unless there's a usable extension", {
  expect_null(file_ext_safe(NULL))
  expect_null(file_ext_safe("foo"))
  expect_null(file_ext_safe("a/b/c/foo"))
  expect_identical(file_ext_safe("foo.wut"), "wut")
})
