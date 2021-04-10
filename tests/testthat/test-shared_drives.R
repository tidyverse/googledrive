test_that("new_corpus() checks type and length, if not-NULL", {
  expect_silent(new_corpus())
  expect_silent(
    new_corpus(driveId = "1", corpora = "b", includeItemsFromAllDrives = FALSE)
  )
  expect_error(
    new_corpus(driveId = c("1", "2")),
    "length\\(driveId\\) == 1 is not TRUE"
  )
  expect_error(
    new_corpus(corpora = c("a", "b")),
    "is_string\\(corpora\\) is not TRUE"
  )
  expect_error(
    new_corpus(includeItemsFromAllDrives = c(TRUE, FALSE)),
    "length\\(includeItemsFromAllDrives\\) == 1 is not TRUE"
  )
})

test_that("`corpora` is checked for validity", {
  expect_silent(shared_drive_params(corpora = "user"))
  expect_silent(shared_drive_params(corpora = "allDrives"))
  expect_silent(shared_drive_params(corpora = "domain"))
  expect_error(
    shared_drive_params(corpora = "foo"),
    "Invalid value for `corpora`"
  )
})

test_that('`corpora = "drive"` requires shared drive specification', {
  expect_error(
    shared_drive_params(corpora = "drive"),
    "`shared_drive` cannot be NULL"
  )
})

test_that('`corpora != "drive"` rejects shared drive specification', {
  expect_error(
    shared_drive_params(corpora = "user", driveId = "123"),
    "don't specify a shared drive"
  )
})

test_that("a shared drive can be specified w/ corpora", {
  expect_silent(shared_drive_params(corpora = "drive", driveId = "123"))
})

test_that('`corpora = "drive" is inferred from shared drive specification', {
  out <- shared_drive_params(driveId = "123")
  expect_identical(out$corpora, "drive")
})
