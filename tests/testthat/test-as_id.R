context("Drive id class")

# ---- tests ----
test_that("as_id() returns non-URL character strings as ids", {

  expect_s3_class(as_id("12345"), "drive_id")

  expect_identical(as_id("12345")[1], "12345")

  expect_identical(as_id(character(0)), character(0))
})

test_that("as_id() extracts ids from Drive URLs but not other URLs", {
  x <- c(
    "https://docs.google.com/document/d/doc12345/edit",
    "https://drive.google.com/drive/folders/folder12345",
    "https://drive.google.com/open?id=blob12345",
    "https://docs.google.com/a/example.com/spreadsheets/d/team12345"
  )
  expect_identical(
    as_id(x),
    as_id(c("doc12345", "folder12345", "blob12345", "team12345"))
  )
  ## properly recognizes a missing URL
  x <- c(
    "https://docs.google.com/document/d/doc12345/edit",
    NA,
    "https://drive.google.com/open?id=blob12345"
  )
  expect_identical(as_id(x), as_id(c("doc12345", NA, "blob12345")))

  ## properly recognizes a non-conforming URL
  x <- "http://example.com"
  expect_identical(as_id(x)[1], NA_character_)
})
