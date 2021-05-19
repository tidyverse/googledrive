test_that("root_folder() and root_id() work", {
  expect_snapshot(
    root_folder()
  )
  expect_snapshot(
    root_id()
  )
})
