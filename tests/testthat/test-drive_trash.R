context("Trash files")

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
  drive_rm(nm_("foo"))
}

test_that("drive_trash() moves file to trash and drive_untrash() undoes", {
  skip_on_travis()
  skip_on_appveyor()
  skip_if_offline()

  out <- drive_trash(nm_("foo"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("foo"))
  expect_true(out[["files_resource"]][[1]][["trashed"]])

  out <- drive_untrash(nm_("foo"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("foo"))
  expect_false(out[["files_resource"]][[1]][["trashed"]])
})

## WARNING: this will empty your drive trash. If you do
## not want that to happen, set EMPTY_TRASH = FALSE
# EMPTY_TRASH = TRUE

# test_that("drive_empty_trash() empties trash", {
#   skip_on_travis()
#   skip_on_appveyor()
#   skip_if_offline()
#   skip_if_not(EMPTY_TRASH)
#   expect_message(drive_empty_trash())
#   expect_identical(nrow(drive_view_trash()), 0L)
# })
