# ---- tests ----
test_that("drive_fields() returns nothing, if no input", {
  expect_identical(drive_fields(), character())
})

test_that("drive_fields(expose()) returns full tibble of Files fields", {
  expect_identical(
    drive_fields(expose()),
    .drive$files_fields
  )
  out <- drive_fields(expose(), resource = "foo")
  expect_identical(out, drive_fields(expose()))
})

test_that("drive_fields() admits it only knows about Files fields", {
  local_drive_loud_and_wide()

  x <- letters[1:6]
  expect_snapshot(
    out <- drive_fields(x, resource = "foo")
  )
  expect_identical(out, x)
})

test_that("drive_fields() detects bad fields", {
  local_drive_loud_and_wide()
  expect_snapshot(
    out <- drive_fields(c("name", "parents", "ownedByMe", "pancakes!"))
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
