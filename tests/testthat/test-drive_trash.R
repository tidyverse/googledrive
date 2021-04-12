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
    me_("trashee-1"),
    me_("trashee-2")
  ))
}

# ---- tests ----
test_that("drive_trash() moves files to trash and drive_untrash() undoes", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(drive_find(me_("trashee-[12]"))))

  trashee1 <- drive_cp(nm_("trash-fodder"), name = me_("trashee-1"))
  trashee2 <- drive_cp(nm_("trash-fodder"), name = me_("trashee-2"))

  out <- drive_trash(c(me_("trashee-1"), me_("trashee-2")))
  expect_s3_class(out, "dribble")
  expect_identical(sort(out$name), sort(c(me_("trashee-1"), me_("trashee-2"))))
  expect_true(all(drive_reveal(out, "trashed")[["trashed"]]))

  out <- drive_untrash(c(me_("trashee-1"), me_("trashee-2")))
  expect_s3_class(out, "dribble")
  expect_identical(sort(out$name), sort(c(me_("trashee-1"), me_("trashee-2"))))
  expect_false(any(drive_reveal(out, "trashed")[["trashed"]]))
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
