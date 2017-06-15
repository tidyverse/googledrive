context("Lookup mime type")

test_that("drive_mime_type() returns the a mime type if given a Google type",{
  expect_identical(drive_mime_type(c("spreadsheet", "document")),
               c("application/vnd.google-apps.spreadsheet",
                 "application/vnd.google-apps.document"))
})

test_that("drive_mime_type() returns the a mime type if given a file extension",{
  expect_identical(drive_mime_type(c("pdf","jpeg")),
               c("application/pdf", "image/jpeg"))
})

test_that("drive_mime_type() errors if given nonsense",{
  expect_error(drive_mime_type("nonsense"), "We do not know a mime type for files of type")
  expect_error(drive_mime_type(1), "Please update `type` to be a character string.")
})
