# ---- tests ----
test_that("drive_rm() copes with no input", {
  expect_identical(drive_rm(), dribble())
})

test_that("drive_rm() copes when there are no matching files", {
  skip_if_no_token()
  skip_if_offline()

  expect_identical(drive_rm("non-existent-file-name"), dribble())
})
