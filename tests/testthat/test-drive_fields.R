context("Fields")

# ---- tests ----
test_that("drive_fields() returns nothing, if no input", {
  expect_identical(drive_fields(), character())
})

test_that("drive_fields(expose()) returns full tibble of Files fields", {
  expect_identical(
    drive_fields(expose()),
    .drive$files_fields
  )

  expect_message(
    out <- drive_fields(expose(), resource = "foo"),
    "ALERT! Only fields for the `files` resource are built-in."
  )
  expect_identical(out, drive_fields(expose()))
})

test_that("drive_fields() admits it only knows about Files fields", {
  expect_message(
    out <- drive_fields(NULL, resource = "foo"),
    "ALERT! Only fields for the `files` resource are built-in."
  )
  expect_identical(out, drive_fields())

  x <- letters[1:6]
  expect_message(
    out <- drive_fields(x, resource = "foo"),
    "ALERT! Only fields for the `files` resource are built-in."
  )
  expect_identical(out, x)
})

test_that("drive_fields() detects bad fields", {
  expect_warning(
    out <- drive_fields(c("name", "parents", "ownedByMe", "pancakes!")),
    "Ignoring fields that are non-standard"
  )
  expect_identical(out, c("name", "parents", "ownedByMe"))
})

test_that("prep_fields() concatenates input", {
  expect_identical(
    prep_fields(letters[1:2]),
    "files/a,files/b"
  )
  expect_identical(
    prep_fields(letters[1:2], resource = NULL),
    "a,b"
  )
  expect_identical(
    prep_fields(letters[1:2], resource = "blah"),
    "blah/a,blah/b"
  )
})
