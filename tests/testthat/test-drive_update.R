context("Update files")

# ---- nm_fun ----
nm_ <- nm_fun("-TEST-drive-update")

# ---- clean ----
if (CLEAN) {
  drive_rm(c(
    nm_("update-me"),
    nm_("not-unique"),
    nm_("does-not-exist")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_upload(system.file("DESCRIPTION"), nm_("update_me"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
}

# ---- tests ----
test_that("drive_update() updates file", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  updatee <- drive_find(nm_("update_me"))
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
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  expect_error(
    drive_update(nm_("not-unique"), system.file("DESCRIPTION")),
    "Path to update is not unique"
  )
})

test_that("drive_update() informatively errors if the path does not exist",{
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  expect_error(
    drive_update(nm_("does-not-exist"), system.file("DESCRIPTION")),
    "Input does not hold at least one Drive file"
  )
})
