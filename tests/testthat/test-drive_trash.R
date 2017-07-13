context("Trash files")

## WARNING: this will empty your drive trash. If you do
## not want that to happen, set EMPTY_TRASH = FALSE
# EMPTY_TRASH = TRUE

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)


nm_ <- nm_fun("-TEST-drive-trash")

## setup
if (FALSE) {
  drive_mkdir(nm_("foo"))
}

## clean
if (FALSE) {
  del <- drive_rm(nm_("foo"), verbose = FALSE)
}


test_that("drive_trash() moves object to the trash and drive_untrash() undoes", {

  skip_on_travis()
  skip_on_appveyor()
  skip_if_offline()

  expect_true(drive_trash(nm_("foo")))
  foo <- drive_find(nm_("foo"), q = "trashed = true")
  foo <- promote(foo, "trashed")
  expect_true(foo$trashed)

  expect_true(drive_untrash(nm_("foo")))
  foo <- drive_find(nm_("foo"))
  foo <- promote(foo, "trashed")
  expect_false(foo$trashed)
})

# test_that("drive_empty_trash() empties trash", {
#   skip_on_travis()
#   skip_on_appveyor()
#   skip_if_offline()
#   skip_if_not(EMPTY_TRASH)
#   expect_message(drive_empty_trash())
#   expect_identical(nrow(drive_view_trash()), 0L)
# })
