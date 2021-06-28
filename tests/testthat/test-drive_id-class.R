# ---- other ----
if (FALSE) {
  ## how the test file was created
  ## see also test-dplyr-compatbility.R
  saveRDS(
    drive_find(n_max = 10),
    test_file("just_a_dribble.rds")
  )
}

# ---- tests ----
test_that("as_id() copes with NULL, length-0 input, no input", {
  expect_null(as_id())
  expect_null(as_id(NULL))
  expect_null(as_id(NULL))
  expect_identical(as_id(character(0)), character(0))
})

test_that("as_id() errors for unanticipated input", {
  expect_snapshot(as_id(mean), error = TRUE)
  expect_snapshot(as_id(1.2), error = TRUE)
  expect_snapshot(as_id(1L), error = TRUE)
})

test_that("as_id() returns non-URL character strings as ids", {
  expect_s3_class(as_id(c("123", "456")), "drive_id")
  expect_identical(unclass(as_id(c("123", "456"))), c("123", "456"))
})

test_that("as_id() extracts ids from Drive URLs but not other URLs", {
  x <- c(
    "https://docs.google.com/document/d/doc12345/edit",
    "https://drive.google.com/drive/folders/folder12345",
    "https://drive.google.com/open?id=blob12345",
    "https://docs.google.com/a/example.com/spreadsheets/d/team12345",
    ## Team Drive URL
    "https://drive.google.com/drive/u/0/folders/teamdrive12345"
  )
  expect_identical(
    as_id(x),
    as_id(c(
      "doc12345", "folder12345", "blob12345",
      "team12345", "teamdrive12345"
    ))
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
  expect_identical(unclass(as_id(x)), NA_character_)
})

test_that("as_id() works with dribble and dribble-ish data frames", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_s3_class(as_id(x), "drive_id")
  expect_identical(as_id(x), x$id)

  class(x) <- class(x)[-1]
  expect_s3_class(as_id(x), "drive_id")
  expect_identical(as_id(x), x$id)
})
