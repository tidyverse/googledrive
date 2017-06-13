context("Lookup mime type")

test_that("drive_mime_type() returns the a mime type if given a Google type",{
  expect_equal(drive_mime_type("spreadsheet"),
               "application/vnd.google-apps.spreadsheet")

  expect_equal(drive_mime_type(c("spreadsheet", "document")),
               c("application/vnd.google-apps.spreadsheet",
                 "application/vnd.google-apps.document"))
})

test_that("drive_mime_type() returns the a mime type if given a file extension",{
  expect_equal(drive_mime_type("pdf"),
               "application/pdf")
  expect_equal(drive_mime_type(c("pdf", "jpeg")),
               c("application/pdf", "image/jpeg"))
})

test_that("drive_mime_type() returns NA if given nonsense",{
  expect_equal(drive_mime_type("nonsense"),
               NA_character_)

  expect_message(drive_mime_type("nonsense"),
                 "We do not have a mime type for files of type:")

  expect_error(drive_mime_type(1))

  expect_equal(drive_mime_type(character(0)),
               character(0))

  expect_equal(drive_mime_type(c("nonsense", "spreadsheet")),
               c(NA, "application/vnd.google-apps.spreadsheet"))
})
