context("Update files")

# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-update")
nm_ <- nm_fun("TEST-drive-update", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("update-fodder"),
    nm_("not-unique"),
    nm_("does-not-exist")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_upload(system.file("DESCRIPTION"), nm_("update-fodder"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
}

# ---- tests ----
test_that("drive_update() updates file", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("update-me")))

  updatee <- drive_cp(nm_("update-fodder"), name = me_("update-me"))
  tmp <- tempfile()
  now <- as.character(Sys.time())
  writeLines(now, tmp)

  out <- drive_update(updatee, tmp)
  expect_identical(out$id, updatee$id)
  drive_download(updatee, tmp, overwrite = TRUE)
  now_out <- readLines(tmp)
  expect_identical(now, now_out)
})

test_that("drive_update() informatively errors if the path is not unique",{
  skip_if_no_token()
  skip_if_offline()
  expect_error(
    drive_update(nm_("not-unique"), system.file("DESCRIPTION")),
    "File to update is not unique"
  )
})

test_that("drive_update() informatively errors if the path does not exist",{
  skip_if_no_token()
  skip_if_offline()
  expect_error(
    drive_update(nm_("does-not-exist"), system.file("DESCRIPTION")),
    "Input does not hold at least one Drive file"
  )
})

test_that("drive_update() works for multipart updates",{
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(c(me_("update-me"), me_("update-me-new"))))

  updatee <- drive_cp(nm_("update-fodder"), name = me_("update-me"))
  tmp <- tempfile()
  now <- as.character(Sys.time())
  writeLines(now, tmp)

  out <- drive_update(updatee, media = tmp, name = me_("update-me-new"))
  expect_identical(out$id, updatee$id)
  drive_download(updatee, tmp, overwrite = TRUE)
  now_out <- readLines(tmp)
  expect_identical(now, now_out)
  expect_identical(out$name, me_("update-me-new"))
})
