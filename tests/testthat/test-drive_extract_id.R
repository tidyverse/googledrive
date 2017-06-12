context("Extract id from URL")

test_that("drive_extract_id() is properly vectorized", {
  x <- c("/d/12345", "/d/12345")
  expect_equal(drive_extract_id(x), c("12345", "12345"))
  x <- c("/d/12345", "this should not work", "/d/12345")
  expect_equal(drive_extract_id(x), c("12345", NA, "12345"))
  x <- c("12345", "12345")
  expect_equal(drive_extract_id(x), c(NA, NA))
})
