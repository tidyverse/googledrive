test_that("drive_examples_remote() lists the remote example files", {
  skip_if_offline()
  skip_on_cran()

  dat <- drive_examples_remote()
  expect_s3_class(dat, "dribble")
  expect_true(nrow(dat) > 0)

  dat <- drive_examples_remote("chicken")
  expect_s3_class(dat, "dribble")
  expect_true(nrow(dat) > 0)
})

test_that("drive_example_remote() errors when >1 match", {
  skip_if_offline()
  skip_on_cran()

  expect_snapshot(
    drive_example_remote("chicken"),
    error = TRUE
  )
})

test_that("drive_examples_local() lists the local example files", {
  all_files <- drive_examples_local()
  expect_true(all(file.exists(all_files)))

  chicken_files <- drive_examples_local("chicken")
  expect_match(chicken_files, "chicken")
})

test_that("drive_example_local() errors when >1 match", {
  expect_snapshot(
    drive_example_local("chicken"),
    error = TRUE
  )
})

test_that("drive_examples_local() errors when no match", {
  expect_snapshot(
    drive_examples_local("platypus"),
    error = TRUE
  )
})
