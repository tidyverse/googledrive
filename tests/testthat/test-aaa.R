context("Just-a-prop")

test_that("I know who the travis user is", {
  expect_equivalent("nope", Sys.info()["user"])
})
