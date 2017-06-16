context("MIME type helper")

test_that("drive_mime_type() returns table if no input", {
  out <- drive_mime_type()
  expect_is(out, "tbl_df")
  expect_gt(nrow(out), 0)
})

test_that("drive_mime_type() returns MIME type for Drive native type",{
  expect_identical(
    drive_mime_type(c("spreadsheet", "document")),
    c("application/vnd.google-apps.spreadsheet",
      "application/vnd.google-apps.document")
  )
})

test_that("drive_mime_type() returns MIME type for file extension",{
  expect_identical(
    drive_mime_type(c("pdf","jpeg")),
    c("application/pdf", "image/jpeg")
  )
})

test_that("drive_mime_type() returns MIME type for MIME type",{
  input <- c("application/vnd.ms-excel","text/html")
  expect_identical(drive_mime_type(input), input)
})

test_that("drive_mime_type() returns MIME type for mixed input",{
  input <- c("text/html", NA, "folder", "csv")
  expect_identical(
    drive_mime_type(input),
    c("text/html", NA, "application/vnd.google-apps.folder", "text/csv")
  )
})

test_that("drive_mime_type() errors for invalid input",{
  expect_error(drive_mime_type(1), "`type` must be character")
  expect_error(drive_mime_type(dribble()), "`type` must be character")
})

test_that("drive_mime_type() errors for single unrecognized input",{
  expect_error(drive_mime_type("nonsense"), "Unrecognized `type`")
})
