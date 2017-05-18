test_that("drive_publish doesn't explicitly fail", {

  skip_on_appveyor()
  skip_on_travis()
  ## upload a file
  write.table(chickwts, "chickwts.txt")
  drive_chickwts <- drive_upload("chickwts.txt", verbose = FALSE)

  ## since we haven't checked the publication status,
  ## this should be NULL
  expect_equal(drive_chickwts$publish, NULL)

  drive_chickwts <- drive_publish(drive_chickwts)

  ## now we should have a tibble with publication information
  expect_equal(nrow(drive_chickwts$publish), 1)

  ## the published column should be TRUE
  expect_true(drive_chickwts$publish$published)

  ## let's unpublish it

  drive_chickwts <- drive_publish(drive_chickwts, publish = FALSE)

  ## now this sould be false
  expect_false(drive_chickwts$publish$published)

  ## clean up
  drive_delete(drive_chickwts)
  rm <- file.remove("chickwts.txt")
})

