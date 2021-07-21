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
test_that("as_id() copes with no input, NULL, and length-0 input", {
  expect_null(as_id())
  expect_null(as_id(NULL))
  expect_identical(as_id(character()), new_drive_id())
})

test_that("as_id() errors for unanticipated input", {
  expect_snapshot(as_id(mean), error = TRUE)
  expect_snapshot(as_id(1.2), error = TRUE)
  expect_snapshot(as_id(1L), error = TRUE)
})

test_that("as_id() returns non-URL character strings as ids", {
  expect_true(is_drive_id(as_id(c("123", "456"))))
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

  expect_true(is_drive_id(as_id(x)))
  expect_identical(as_id(x), x$id)

  class(x) <- class(x)[-1]
  expect_true(is_drive_id(as_id(x)))
  expect_identical(as_id(x), x$id)
})

test_that("presence of drive_id column doesn't prevent row binding of dribbles", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  alfa <- x[1:2, ]
  bravo <- x[3:4, ]

  expect_error_free(
    out <- vec_rbind(alfa, bravo)
  )
  expect_equal(out[c("name", "id")], x[1:4, c("name", "id")])
})

## how drive_ids look when printed
test_that("drive_id's are formatted OK", {
  x <- readRDS(test_file("just_a_dribble.rds"))
  expect_snapshot(print(x$id))
})

test_that("drive_ids look OK in a dribble and truncate gracefully", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_snapshot(print(x))
  expect_snapshot(print(drive_reveal(x, "mime_type")))

  x$id[1] <- NA
  expect_snapshot(print(x))
})

test_that("gargle_map_cli() is implemented for drive_id", {
  expect_snapshot(
    gargle_map_cli(as_id(month.name[1:3]))
  )
})

## low-level helpers
test_that("new_drive_id() handles 0-length input and NA", {
  expect_error_free(
    out <- new_drive_id(character())
  )
  expect_length(out, 0)
  expect_true(is_drive_id(out))

  expect_error_free(
    out <- new_drive_id(NA_character_)
  )
  expect_true(is.na(out))
  expect_true(is_drive_id(out))

  expect_error_free(
    out <- new_drive_id(c(NA_character_, "abc"))
  )
  expect_true(is.na(out[1]))
  expect_true(is_drive_id(out))
})

test_that("validate_drive_id fails informatively", {
  expect_snapshot(validate_drive_id(""), error = TRUE)
  expect_snapshot(validate_drive_id("a@&"), error = TRUE)
})

test_that("drive_id is dropped when combining with character", {
  x <- as_id("abc")
  y <- "def"

  out <- vec_c(x, y)
  expect_identical(out, c("abc", "def"))
  expect_false(is_drive_id(out))

  out <- vec_c(y, x)
  expect_identical(out, c("def", "abc"))
  expect_false(is_drive_id(out))
})

test_that("you can't insert invalid strings into a drive_id", {
  x <- as_id(month.name)
  expect_true(is_drive_id(x))
  expect_snapshot(x[2] <- "", error = TRUE)
})
