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
