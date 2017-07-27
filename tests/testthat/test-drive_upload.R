context("Upload files")

# ---- nm_fun ----
nm_ <- nm_fun("-TEST-drive-upload")

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("upload-into-me"),
    nm_("DESCRIPTION")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("upload-into-me"))
}

# ---- tests ----
test_that("drive_upload() detects non-existent file", {
  expect_error(drive_upload("no-such-file"), "File does not exist")
})

test_that("drive_upload() places file in non-root folder, with new name", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  on.exit(drive_rm(nm_("DESCRIPTION")))

  destination <- drive_get(nm_("upload-into-me"))
  uploadee <- drive_upload(
    system.file("DESCRIPTION"),
    path = destination,
    name = nm_("DESCRIPTION")
  )

  expect_s3_class(uploadee, "dribble")
  expect_identical(nrow(uploadee), 1L)
  expect_identical(uploadee$files_resource[[1]]$parents[[1]], destination$id)
})
