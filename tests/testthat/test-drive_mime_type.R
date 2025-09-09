# ---- tests ----
test_that("drive_mime_type() returns NULL if no input", {
  expect_null(drive_mime_type())
})

test_that("drive_mime_type(expose()) returns the full tibble", {
  expect_identical(
    drive_mime_type(expose()),
    .drive$mime_tbl
  )
})

test_that("drive_mime_type() returns MIME type for Drive native type", {
  expect_identical(
    drive_mime_type(c("spreadsheet", "document")),
    c(
      "application/vnd.google-apps.spreadsheet",
      "application/vnd.google-apps.document"
    )
  )
})

test_that("drive_mime_type() returns MIME type for file extension", {
  expect_identical(
    drive_mime_type(c("pdf", "jpeg", "md")),
    c("application/pdf", "image/jpeg", "text/markdown")
  )
})

test_that("drive_mime_type() returns MIME type for MIME type", {
  input <- c("application/vnd.ms-excel", "text/html", "text/x-markdown")
  expect_identical(drive_mime_type(input), input)
})

test_that("drive_mime_type() returns MIME type for mixed input", {
  input <- c("text/html", NA, "folder", "csv")
  expect_identical(
    drive_mime_type(input),
    c("text/html", NA, "application/vnd.google-apps.folder", "text/csv")
  )
})

test_that("drive_mime_type() errors for invalid input", {
  expect_snapshot(drive_mime_type(1), error = TRUE)
  expect_snapshot(drive_mime_type(dribble()), error = TRUE)
})

test_that("drive_mime_type() errors for single unrecognized input", {
  expect_snapshot(drive_mime_type("nonsense"), error = TRUE)
})

test_that("drive_extension() returns NULL if no input", {
  expect_null(drive_extension())
})

test_that("drive_extension() returns file extension for MIME type", {
  expect_identical(
    drive_extension(c("application/pdf", "image/jpeg", "text/x-markdown")),
    c("pdf", "jpeg", "md")
  )
})

test_that("drive_extension() returns file extension for file extension", {
  input <- c("xlsx", "html")
  expect_identical(drive_extension(input), input)
})

test_that("drive_extension() returns file extension for mixed input", {
  input <- c("text/html", NA, "application/vnd.google-apps.folder", "csv")
  expect_identical(
    drive_extension(input),
    c("html", NA, NA, "csv")
  )
})

test_that("drive_extension() errors for invalid input", {
  expect_snapshot(drive_extension(1), error = TRUE)
  expect_snapshot(drive_extension(dribble()), error = TRUE)
})

test_that("drive_extension() errors for single unrecognized input", {
  expect_snapshot(drive_extension("nonsense"), error = TRUE)
})
