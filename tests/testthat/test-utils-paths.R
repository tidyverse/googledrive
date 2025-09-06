# ---- nm_fun ----
me_ <- nm_fun("TEST-utils-paths")
nm_ <- nm_fun("TEST-utils-paths", user_run = FALSE)

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
test_that("root_folder() and root_id() work", {
  skip_if_no_token()
  skip_if_offline()

  expect_snapshot(
    root_folder()
  )
  expect_snapshot(
    root_id()
  )
})

test_that("rootize_path() standardizes root", {
  expect_identical(rootize_path(NULL), NULL)
  expect_identical(rootize_path(character()), character())
  expect_identical(rootize_path("~"), "~/")
  expect_identical(rootize_path("~/"), "~/")
})

test_that("rootize_path() errors for leading slash", {
  expect_snapshot(rootize_path("/"), error = TRUE)
  expect_error(rootize_path("/abc"))
})

test_that("append_slash() appends a slash or declines to do so", {
  expect_identical(append_slash("a"), "a/")
  expect_identical(append_slash("a/"), "a/")
  expect_identical(append_slash(""), "")
  expect_identical(append_slash(c("a", "")), c("a/", ""))
  expect_identical(append_slash(character(0)), character(0))
})

test_that("strip_slash() strips a trailing slash", {
  expect_identical(strip_slash("a"), "a")
  expect_identical(strip_slash("a/"), "a")
  expect_identical(strip_slash(""), "")
  expect_identical(strip_slash(character(0)), character(0))
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

  ## maybe_name = TRUE --> use `path` as is, don't append slash
  expect_identical(partition_path("~/a", TRUE), f("~/", "a"))
  expect_identical(partition_path("a/", TRUE), f("a/", NULL))
  expect_identical(partition_path("a", TRUE), f(NULL, "a"))

  expect_identical(partition_path("~/a/b/", TRUE), f("~/a/b/", NULL))
  expect_identical(partition_path("a/b/", TRUE), f("a/b/", NULL))
  expect_identical(partition_path("a/b", TRUE), f("a/", "b"))
})

test_that("partition_path() fails for bad input", {
  expect_snapshot(partition_path(letters), error = TRUE)
  expect_snapshot(partition_path(dribble()), error = TRUE)
  expect_snapshot(partition_path(as_id("123")), error = TRUE)
})

test_that("is_path() works", {
  expect_true(is_path("a"))
  expect_true(is_path(letters))
  expect_false(is_path(as_id("a")))
  expect_false(is_path(as_id(letters)))
  expect_false(is_path(dribble()))
})

test_that("rationalize_path_name() errors for bad `name`, before hitting API", {
  expect_snapshot(rationalize_path_name(name = letters), error = TRUE)
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
  local_mocked_bindings(
    confirm_clear_path = function(path, name) NULL
  )
  expect_identical(
    rationalize_path_name(path = "FILE_NAME", name = NULL),
    list(path = NULL, name = "FILE_NAME")
  )
  expect_identical(
    rationalize_path_name(path = "PARENT_FOLDER/FILE_NAME", name = NULL),
    list(path = "PARENT_FOLDER/", name = "FILE_NAME")
  )
})

test_that("check_for_overwrite() does its job", {
  skip_if_no_token()
  skip_if_offline()

  withr::defer(drive_empty_trash())
  defer_drive_rm(file.path(nm_("create-in-me"), me_("name-collision")))

  PARENT_ID <- drive_get(nm_("create-in-me"))$id

  first <- drive_create(me_("name-collision"), path = PARENT_ID)

  expect_error(
    check_for_overwrite(
      parent = PARENT_ID,
      name = me_("name-collision"),
      overwrite = FALSE
    ),
    "already exist"
  )

  expect_no_error(
    second <- drive_create(
      me_("name-collision"),
      path = PARENT_ID,
      overwrite = TRUE
    )
  )
  expect_identical(first$name, second$name)
  expect_identical(
    drive_reveal(first, "parent")$id_parent,
    drive_reveal(second, "parent")$id_parent
  )
  expect_false(first$id == second$id)

  expect_no_error(
    drive_create(
      me_("name-collision"),
      path = PARENT_ID,
      overwrite = NA
    )
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
