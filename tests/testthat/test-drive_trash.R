# ---- nm_fun ----
me_ <- nm_fun("TEST-drive_trash")
nm_ <- nm_fun("TEST-drive_trash", user_run = FALSE)

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
  defer_drive_rm(drive_find(me_("trashee-[12]")))

  trashee1 <- drive_cp(nm_("trash-fodder"), name = me_("trashee-1"))
  trashee2 <- drive_cp(nm_("trash-fodder"), name = me_("trashee-2"))

  out <- drive_trash(c(me_("trashee-1"), me_("trashee-2")))
  expect_dribble(out)
  expect_setequal(out$name, c(me_("trashee-1"), me_("trashee-2")))
  expect_true(all(drive_reveal(out, "trashed")[["trashed"]]))

  out <- drive_untrash(c(me_("trashee-1"), me_("trashee-2")))
  expect_dribble(out)
  expect_setequal(out$name, c(me_("trashee-1"), me_("trashee-2")))
  expect_false(any(drive_reveal(out, "trashed")[["trashed"]]))
})
