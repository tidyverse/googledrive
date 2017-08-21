context("Utils")

# ---- tests ----
test_that("Sys_getenv() requires length 1 input", {
  expect_error(Sys_getenv(letters), "length(x) == 1 is not TRUE", fixed = TRUE)
})

test_that("Sys_getenv() is Sys.getenv() for env var that is set", {
  expect_identical(Sys_getenv("R_HOME"), Sys.getenv("R_HOME"))
})

test_that("Sys_getenv() returns NULL for env var that is unset", {
  expect_identical(Sys.getenv("zyx"), "")
  expect_null(Sys_getenv("zyx"))
})

test_that("put_column() adds a column in the right place", {
  df <- tibble::tibble(v1 = 1, v2 = 2)
  expect_identical(
    put_column(df, insert = 3, .after = "v1"),
    tibble::tibble(v1 = 1, insert = 3, v2 = 2)
  )
})

test_that("put_column() updates an existing column", {
  df <- tibble::tibble(v1 = 1, v2 = 2)
  expect_identical(
    put_column(df, v3 = "hi"),
    tibble::tibble(v1 = 1, v2 = 2, v3 = "hi")
  )
})

test_that("put_column() works with an expression", {
  df <- tibble::tibble(v1 = 1, v2 = 2)
  stuff <- "stuff"
  expect_identical(
    put_column(df, v3 = stuff),
    tibble::tibble(v1 = 1, v2 = 2, v3 = "stuff")
  )
})

test_that("put_column() does nothing if no new column requested", {
  df <- tibble::tibble(v1 = 1, v2 = 2)
  expect_identical(put_column(df), df)
})

test_that("put_column() errors if >1 new column requested", {
  df <- tibble::tibble(v1 = 1, v2 = 2)
  expect_error(
    put_column(df, v3 = 3, v4 = 4),
    "Can only put exactly one column"
  )
})
