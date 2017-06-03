context("Query paths")

test_that("get_path() can return info on root folder", {
  skip_on_appveyor()
  skip_on_travis()

  out <- get_paths("~/")
  expect_length(nrow(out), 1)
  expect_identical(out$path, "~/")
})
