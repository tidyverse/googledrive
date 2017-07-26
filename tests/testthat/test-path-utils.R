context("Path utilities")

# ---- tests ----
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

test_that("is_rootpath() recognizes requests for root folder", {
  expect_true(is_rootpath("~"))
  expect_true(is_rootpath("~/"))
  expect_true(is_rootpath("/"))
  expect_false(is_rootpath(NULL))
  expect_false(is_rootpath(character(0)))
  expect_false(is_rootpath("abc"))
  expect_false(is_rootpath("/abc"))
  expect_false(is_rootpath("~/abc"))
})

test_that("file_ext_safe() returns NULL unless there's a usable extension", {
  expect_null(file_ext_safe(NULL))
  expect_null(file_ext_safe("foo"))
  expect_null(file_ext_safe("a/b/c/foo"))
  expect_identical(file_ext_safe("foo.wut"), "wut")
})

test_that("partition_path() splits into stuff before/after last slash", {
  f <- function(x, y) list(parent = x, name = y)

  expect_identical(partition_path(NULL), f(NULL, NULL))
  expect_identical(partition_path(character(0)), f(NULL, NULL))

  expect_identical(partition_path(""), f(NULL, ""))

  expect_identical(partition_path("~"), f("~/", NULL))
  expect_identical(partition_path("~/"), f("~/", NULL))
  expect_identical(partition_path("/"), f("~/", NULL))

  ## maybe_name = TRUE --> use `path` as is, don't append slash
  expect_identical(partition_path("~/a", TRUE), f("~/", "a"))
  expect_identical(partition_path("/a", TRUE), f("~/", "a"))
  expect_identical(partition_path("/a/", TRUE), f("~/a/", NULL))
  expect_identical(partition_path("a/", TRUE), f("a/", NULL))
  expect_identical(partition_path("a", TRUE), f(NULL, "a"))

  expect_identical(partition_path("~/a/b/", TRUE), f("~/a/b/", NULL))
  expect_identical(partition_path("/a/b/", TRUE), f("~/a/b/", NULL))
  expect_identical(partition_path("a/b/", TRUE), f("a/b/", NULL))
  expect_identical(partition_path("a/b", TRUE), f("a/", "b"))
})

test_that("partition_path() fails for bad input", {
  expect_error(partition_path(letters), "length\\(path\\) == 1 is not TRUE")
  expect_error(partition_path(dribble()), "is_path\\(path\\) is not TRUE")
  expect_error(partition_path(as_id("123"), '!inherits\\(x, "drive_id"\\) is not TRUE'))
})

test_that("is_path() works", {
  expect_true(is_path("a"))
  expect_true(is_path(letters))
  expect_false(is_path(as_id("a")))
  expect_false(is_path(as_id(letters)))
  expect_false(is_path(dribble()))
})
