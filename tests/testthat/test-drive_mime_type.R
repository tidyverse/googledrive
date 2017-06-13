context("Lookup mime type")

test_that("drive_mime_type() returns the a mime type if given a Google type",{
  expect_identical(drive_mime_type("spreadsheet"),
               "application/vnd.google-apps.spreadsheet")
})

test_that("drive_mime_type() returns the a mime type if given a file extension",{
  expect_identical(drive_mime_type("pdf"),
               "application/pdf")
})

test_that("drive_mime_type() returns NULL if given nonsense",{
  expect_null(drive_mime_type("nonsense"))

  expect_message(drive_mime_type("nonsense"),
                 "Ignoring `type` input. We do not have a mime type for files of type:")

  expect_error(drive_mime_type(1), "Please update `type` to be a character string.")
})
