context("Dribble class")

# ---- tests ----
test_that("dribble() creates empty dribble", {
  expect_s3_class(dribble(), "dribble")
  expect_equal(nrow(dribble()), 0)
})

test_that("new_dribble() requires data.frame and adds the dribble class", {
  expect_error(
    new_dribble(1:3),
    'inherits\\(x, "data.frame"\\) is not TRUE'
  )
  expect_s3_class(new_dribble(data.frame(x = 1:3)), "dribble")
})

test_that("validate_dribble() checks class, var names, var types", {
  expect_error(
    validate_dribble("a"),
    'inherits\\(x, "dribble"\\) is not TRUE'
  )

  ## wrong type
  d <- dribble()
  d$id <- numeric()
  expect_error(
    validate_dribble(d),
    "Invalid dribble. These columns have the wrong type"
  )

  ## missing a required variable
  d <- dribble()
  d$name <- NULL
  expect_error(
    validate_dribble(d),
    "Invalid dribble. These required column names are missing"
  )

  ## list-col elements do not have `kind = "drive#file"`
  d <- new_dribble(
    tibble::tibble(
      name = "a",
      id = "1",
      files_resource = list(kind = "whatever")
    )
  )
  expect_error(
    validate_dribble(d),
    "Invalid dribble. Can't confirm `kind = \"drive#file\"`"
  )
})

test_that("as_tibble() drops the dribble class", {
  expect_false(inherits(as_tibble(dribble()), "dribble"))
})

test_that("`[` retains dribble class when possible", {
  d <- new_dribble(
    tibble::tibble(
      name = letters[1:4],
      id = letters[4:1],
      files_resource = list(list(kind = "drive#file"))
    )
  )
  expect_s3_class(d, "dribble")
  expect_s3_class(d[1, ], "dribble")
  expect_s3_class(d[1:2, ], "dribble")
  expect_s3_class(d[1:3], "dribble")
  d$foo <- "foo"
  expect_s3_class(d, "dribble")
  expect_s3_class(d[-4], "dribble")
})

test_that("`[` drops dribble class when not valid", {
  d <- new_dribble(
    tibble::tibble(
      name = letters[1:4],
      id = letters[4:1],
      files_resource = list(list(kind = "drive#file"))
    )
  )
  expect_s3_class(d, "dribble")
  expect_false(inherits(d[1], "dribble"))
  expect_false(inherits(d[ , 1], "dribble"))
})

test_that("dribble nrow checkers work", {
  expect_true(no_file(dribble()))
  expect_false(single_file(dribble()))
  expect_false(some_files(dribble()))
  expect_error(
    confirm_single_file(dribble()),
    "Input does not hold exactly one Drive file"
  )
  expect_error(
    confirm_some_files(dribble()),
    "Input does not hold at least one Drive file"
  )

  d <- new_dribble(
    tibble::tibble(
      name = "a",
      id = "b",
      files_resource = list(list(kind = "drive#file"))
    )
  )
  expect_false(no_file(d))
  expect_true(single_file(d))
  expect_true(some_files(d))
  expect_identical(confirm_single_file(d), d)
  expect_identical(confirm_some_files(d), d)

  d <- d[c(1, 1), ]
  expect_false(no_file(d))
  expect_false(single_file(d))
  expect_true(some_files(d))
  expect_error(
    confirm_single_file(d),
    "Input does not hold exactly one Drive file"
  )
  expect_identical(confirm_some_files(d), d)
})

test_that("is_folder() works", {
  expect_identical(is_folder(dribble()), logical(0))
  d <- new_dribble(
    tibble::tribble(
      ~ name, ~ id, ~ files_resource,
      "a", "aa", list(mimeType = "application/vnd.google-apps.folder"),
      "b", "bb", list(mimeType = "foo")
    )
  )
  expect_identical(is_folder(d), c(TRUE, FALSE))
})

test_that("as_dribble(NULL) returns empty dribble", {
  expect_identical(as_dribble(), dribble())
})

test_that("as_dribble() default method handles unsuitable input", {
  expect_error(
    as_dribble(1.3),
    "Don't know how to coerce object of class numeric into a dribble"
  )
  expect_error(
    as_dribble(TRUE),
    "Don't know how to coerce object of class logical into a dribble"
  )
})

test_that("as_dribble.list() works for good input", {
  drib_lst <- list(
    name = "name",
    id = "id",
    kind = "drive#file"
  )
  expect_silent(d <- as_dribble(list(drib_lst)))
  expect_s3_class(d, "dribble")
})

test_that("as_dribble.list() catches bad input", {
  ## not testing error messages, as_dribble.list() intended for internal use
  drib_lst <- list(
    name = "name"
  )
  expect_error(as_dribble(list(drib_lst)))

  drib_lst <- list(
    name = "name",
    id = "id",
    kind = "whatever"
  )
  expect_error(as_dribble(list(drib_lst)))
})

test_that("promote() works when elem present, absent, and input is trivial", {
  x <- tibble::tibble(
    name = c("a", "b", "c"),
    id = c("1", "2", "3"),
    files_resource = list(
      list(foo = "a1"),
      list(foo = "b2"),
      list(foo = "c3", baz = "c3")
    )
  )

  ## foo is uniformly present
  out <- promote(x, "foo")
  expect_identical(
    out,
    tibble::tibble(
      name = x$name,
      foo = c("a1", "b2", "c3"),
      id = x$id,
      files_resource = x$files_resource
    )
  )

  ## bar is uniformly absent
  out <- promote(x, "bar")
  expect_identical(
    out,
    tibble::tibble(
      name = x$name,
      bar = list(NULL, NULL, NULL),
      id = x$id,
      files_resource = x$files_resource
    )
  )

  ## baz is present sometimes
  out <- promote(x, "baz")
  expect_identical(
    out,
    tibble::tibble(
      name = x$name,
      baz = list(NULL, NULL, "c3"),
      id = x$id,
      files_resource = x$files_resource
    )
  )

  ## input dribble has zero rows
  out <- promote(dribble(), "bar")
  expect_identical(
    out,
    as_dribble(
      tibble::tibble(
        name = character(0),
        bar = list(),
        id = character(0),
        files_resource = list()
      )
    )
  )
})
