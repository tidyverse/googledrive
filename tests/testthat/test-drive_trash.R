context("Trash files")

# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-trash")
nm_ <- nm_fun("TEST-drive-trash", NULL)

# ---- setup ----
if (SETUP) {
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("trash-fodder")
  )
}

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("trash-fodder"),
    me_("trashee")
  ))
}

# ---- tests ----
test_that("drive_trash() moves file to trash and drive_untrash() undoes", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("trashee")))

  trashee <- drive_cp(nm_("trash-fodder"), name = me_("trashee"))

  out <- drive_trash(me_("trashee"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("trashee"))
  expect_true(out[["files_resource"]][[1]][["trashed"]])

  out <- drive_untrash(me_("trashee"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("trashee"))
  expect_false(out[["files_resource"]][[1]][["trashed"]])
})

## WARNING: this will empty your drive trash. If you do
## not want that to happen, set EMPTY_TRASH = FALSE
# EMPTY_TRASH = FALSE

# test_that("drive_empty_trash() empties trash", {
# skip_if_no_token()
# skip_if_offline()
# skip_if_not(EMPTY_TRASH)
# expect_message(drive_empty_trash())
# expect_identical(nrow(drive_view_trash()), 0L)
# })
