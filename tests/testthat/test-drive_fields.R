context("Fields")

test_that("drive_fields() returns built in Files fields", {
  expect_identical(
    drive_fields(which = "all"),
    .drive$files_fields[["name"]]
  )
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
