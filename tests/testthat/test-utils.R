# ---- tests ----
test_that("put_column() adds a column in the right place", {
  df <- tibble(v1 = 1, v2 = 2)
  expect_identical(
    put_column(df, nm = "insert", val = 3, .after = "v1"),
    tibble(v1 = 1, insert = 3, v2 = 2)
  )
})

test_that("put_column() updates an existing column", {
  df <- tibble(v1 = 1, v2 = 2)
  expect_identical(
    put_column(df, nm = "v3", val = "hi"),
    tibble(v1 = 1, v2 = 2, v3 = "hi")
  )
})

test_that("put_column() works with an expression", {
  df <- tibble(v1 = 1, v2 = 2)
  stuff <- "stuff"
  expect_identical(
    put_column(df, nm = "v3", val = stuff),
    tibble(v1 = 1, v2 = 2, v3 = "stuff")
  )
})

test_that("and() protects its inputs with parentheses", {
  x <- c("organizerCount > 5", "memberCount > 20")
  expect_identical(
    as.character(and(c("createdTime > '2019-01-01T12:00:00'", or(x)))),
    "(createdTime > '2019-01-01T12:00:00') and (organizerCount > 5 or memberCount > 20)"
  )
})
