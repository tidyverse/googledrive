test_that("promote() works when input has zero rows", {
  dib <- dribble()
  tib <- as_tibble(dib)
  tib_out <- tibble::add_column(tib, bar = list(), .after = 1)
  dib_out <- as_dribble(tib_out)

  expect_identical(promote(tib, "bar"), tib_out)
  expect_identical(promote(dib, "bar"), dib_out)
})

test_that("promote() works when elem uniformly present or absent", {
  x <- tibble(
    name = c("a", "b", "c"),
    id = c("1", "2", "3"),
    drive_resource = list(
      list(foo = "a1"),
      list(foo = "b2"),
      list(foo = "c3")
    )
  )

  expect_identical(
    promote(x, "foo"),
    tibble::add_column(x, foo = c("a1", "b2", "c3"), .after = 1)
  )

  expect_identical(
    promote(x, "bar"),
    tibble::add_column(x, bar = list(NULL, NULL, NULL), .after = 1)
  )
})

test_that("promote() works when elem is partially present", {
  x <- tibble(
    name = c("a", "b", "c"),
    id = c("1", "2", "3"),
    drive_resource = list(
      list(foo = "a1", bar = TRUE),
      list(foo = "b2", qux = list(letter = "b")),
      list(foo = "c3", baz = "c3")
    )
  )

  expect_identical(
    promote(x, "bar"),
    tibble::add_column(x, bar = c(TRUE, NA, NA), .after = 1)
  )
  expect_identical(
    promote(x, "qux"),
    tibble::add_column(x, qux = list(NULL, list(letter = "b"), NULL), .after = 1)
  )
  expect_identical(
    promote(x, "baz"),
    tibble::add_column(x, baz = c(NA, NA, "c3"), .after = 1)
  )
})

test_that("promote() replaces existing element in situ", {
  x <- tibble(
    name = "a",
    foo = "b",
    bar = "c",
    id = "1",
    drive_resource = list(
      list(foo = "d", bar = "e")
    )
  )
  x2 <- promote(x, "foo")
  x3 <- promote(x2, "bar")
  expect_identical(x3$foo, "d")
  expect_identical(x3$bar, "e")
})

test_that("promote() does snake_case to camelCase conversion internally", {
  x <- tibble(
    name = "name",
    id = "id",
    drive_resource = list(
      list(thisThat = "hi")
    )
  )

  out <- promote(x, "this_that")
  expect_identical(out[2], tibble(this_that = "hi"))

  out <- promote(x, "thisThat")
  expect_identical(out[2], tibble(thisThat = "hi"))
})
