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
