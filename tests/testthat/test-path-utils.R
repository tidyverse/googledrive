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


test_that("split_path_name() works with `name = NULL`", {

  ## with trailing slash, a/ is a folder
  path_name <- split_path_name(path = "a/", name = NULL)
  expect_identical(path_name[["path"]], "a/")
  expect_null(path_name[["name"]])

  ## without trailing slash, a is the name, path is NULL
  path_name <- split_path_name(path = "a", name = NULL)
  expect_null(path_name[["path"]])
  expect_identical(path_name[["name"]], "a")
})

test_that("split_path_name() works with `name != NULL`", {

  ## with trailing slash, a/ is a folder, b is name
  path_name <- split_path_name(path = "a/", name = "b")
  expect_identical(path_name[["path"]], "a/")
  expect_identical(path_name[["name"]], "b")

  ## without trailing slash, a is the name, b is ignored
  expect_message(path_name <- split_path_name(path = "a", name = "b"),
                 "Ignoring `name`:")
  expect_null(path_name[["path"]])
  expect_identical(path_name[["name"]], "a")
})

test_that("split_path_name() returns input if not character", {

  path_name <- split_path_name(path = 1, name = "a")
  expect_identical(path_name[["path"]], 1)
  expect_identical(path_name[["name"]], "a")

  ## returns NULL if both are NULL
  path_name <- split_path_name(path = NULL, name = NULL)
  expect_null(path_name[["path"]])
  expect_null(path_name[["name"]])
})

test_that("partition_path() splits into stuff before/after last slash", {
  f <- function(x, y) list(parent = x, name = y)

  expect_identical(partition_path(NULL), f(NULL, NULL))
  expect_identical(partition_path(character(0)), f(NULL, NULL))

  expect_identical(partition_path(""), f(NULL, ""))

  expect_identical(partition_path("~"), f("~/", NULL))
  expect_identical(partition_path("~/"), f("~/", NULL))
  expect_identical(partition_path("/"), f("~/", NULL))

  expect_identical(partition_path("~/a"), f("~/", "a"))
  expect_identical(partition_path("/a"), f("~/", "a"))
  expect_identical(partition_path("/a/"), f("~/a/", NULL))
  expect_identical(partition_path("a/"), f("a/", NULL))
  expect_identical(partition_path("a"), f(NULL, "a"))

  expect_identical(partition_path("~/a/b/"), f("~/a/b/", NULL))
  expect_identical(partition_path("/a/b/"), f("~/a/b/", NULL))
  expect_identical(partition_path("a/b/"), f("a/b/", NULL))
  expect_identical(partition_path("a/b"), f("a/", "b"))
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
