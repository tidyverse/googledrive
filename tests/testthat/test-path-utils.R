context("Path utilities")

# ---- nm_fun ----
me_ <- nm_fun("TEST-path-utils")
nm_ <- nm_fun("TEST-path-utils", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("create-in-me")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("create-in-me"))
}

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
  expect_identical(append_slash(c("a", "")), c("a/", ""))
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
  expect_error(partition_path(letters), "is_string\\(path\\) is not TRUE")
  expect_error(partition_path(dribble()), "is_string\\(path\\) is not TRUE")
  expect_error(partition_path(as_id("123"), '!inherits\\(x, "drive_id"\\) is not TRUE'))
})

test_that("is_path() works", {
  expect_true(is_path("a"))
  expect_true(is_path(letters))
  expect_false(is_path(as_id("a")))
  expect_false(is_path(as_id(letters)))
  expect_false(is_path(dribble()))
})

test_that("rationalize_path_name() errors for bad `name`, before hitting API", {
  expect_error(
    rationalize_path_name(name = letters),
    "is_string\\(name\\) is not TRUE"
  )
})

test_that("rationalize_path_name() can pass `path` and `name` through, w/o hitting API", {
  # specifically, this happens when `is_path(path)` is FALSE
  expect_identical(
    rationalize_path_name(path = NULL, name = "NAME"),
    list(path = NULL, name = "NAME")
  )
  expect_identical(
    rationalize_path_name(path = as_id("FILE_ID"), name = NULL),
    list(path = as_id("FILE_ID"), name = NULL)
  )
  expect_identical(
    rationalize_path_name(path = as_id("FILE_ID"), name = "NAME"),
    list(path = as_id("FILE_ID"), name = "NAME")
  )
  expect_identical(
    rationalize_path_name(path = dribble(), name = NULL),
    list(path = dribble(), name = NULL)
  )
  expect_identical(
    rationalize_path_name(path = dribble(), name = "NAME"),
    list(path = dribble(), name = "NAME")
  )
})

test_that("rationalize_path_name() won't hit API if we can infer `path` is a folder", {
  expect_identical(
    rationalize_path_name(path = "PARENT_FOLDER", name = "NAME"),
    list(path = "PARENT_FOLDER/", name = "NAME")
  )
  expect_identical(
    rationalize_path_name(path = "PARENT_FOLDER/", name = NULL),
    list(path = "PARENT_FOLDER/", name = NULL)
  )
})

test_that("rationalize_path_name() populates `path` and `name` and correctly", {
  with_mock(
    `googledrive:::confirm_clear_path` = function(path, name) NULL, {
      expect_identical(
        rationalize_path_name(path = "FILE_NAME", name = NULL),
        list(path = NULL, name = "FILE_NAME")
      )
      expect_identical(
        rationalize_path_name(path = "PARENT_FOLDER/FILE_NAME", name = NULL),
        list(path = "PARENT_FOLDER/", name = "FILE_NAME")
      )
    }
  )
})

test_that("check_for_overwrite() does its job", {
  skip_if_no_token()
  skip_if_offline()
  on.exit({
    drive_rm(file.path(nm_("create-in-me"), me_("name-collision")))
    drive_empty_trash()
  })

  PARENT_ID <- drive_get(nm_("create-in-me"))$id

  first <- drive_create(me_("name-collision"), path = as_id(PARENT_ID))

  expect_error(
    check_for_overwrite(
      parent = PARENT_ID,
      name = me_("name-collision"),
      overwrite = FALSE
    ),
    "already exist"
  )

  expect_error_free(
    second <- drive_create(me_("name-collision"), path = as_id(PARENT_ID), overwrite = TRUE)
  )
  expect_identical(first$name, second$name)
  expect_identical(
    purrr::pluck(first, "drive_resource", 1, "parents"),
    purrr::pluck(second, "drive_resource", 1, "parents")
  )
  expect_false(first$id == second$id)

  expect_error_free(
    drive_create(me_("name-collision"), path = as_id(PARENT_ID), overwrite = NA)
  )
  df <- drive_ls(nm_("create-in-me"))
  expect_identical(nrow(df), 2L)

  expect_error(
    check_for_overwrite(
      parent = PARENT_ID,
      me_("name-collision"),
      overwrite = TRUE
    ),
    "Multiple items"
  )
})

test_that("check_for_overwrite() copes with `parent = NULL`", {
  skip_if_no_token()
  skip_if_offline()

  expect_error(
    check_for_overwrite(parent = NULL, nm_("create-in-me"), overwrite = FALSE),
    "already exist"
  )
})
