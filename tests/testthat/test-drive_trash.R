context("Trash files")

## WARNING: this will empty your drive trash. If you do
## not want that to happen, set EMPTY_TRASH = FALSE
EMPTY_TRASH = TRUE

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)


nm_ <- nm_fun("-TEST-drive-trash")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del <- drive_delete(nm_("foo"), verbose = FALSE)
  }
  drive_mkdir(nm_("foo"))
}

test_that("drive_trash() moves object to the trash", {

  skip_on_travis()
  skip_on_appveyor()

  expect_true(drive_trash(nm_("foo")))
  foo <- drive_search(nm_("foo"), q = "trashed = true")
  foo <- promote(foo, "trashed")
  expect_true(foo$trashed)
})

test_that("drive_untrash() moves object out of the trash", {

  skip_on_travis()
  skip_on_appveyor()

  expect_true(drive_untrash(nm_("foo")))
  foo <- drive_search(nm_("foo"))
  foo <- promote(foo, "trashed")
  expect_false(foo$trashed)
})

test_that("drive_empty_trash() empties trash", {
  skip_on_travis()
  skip_on_appveyor()
  skip_if_not(EMPTY_TRASH)
  expect_message(drive_empty_trash())
  expect_identical(nrow(drive_view_trash()), 0L)
})
