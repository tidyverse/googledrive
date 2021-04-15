# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-upload")
nm_ <- nm_fun("TEST-drive-upload", NULL)

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
  expect_snapshot(
    drive_upload("no-such-file", "File does not exist"),
    error = TRUE
  )
})

test_that("drive_upload() places file in non-root folder, with new name", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(me_("DESCRIPTION"))

  destination <- drive_get(nm_("upload-into-me"))
  uploadee <- drive_upload(
    system.file("DESCRIPTION"),
    path = destination,
    name = me_("DESCRIPTION")
  )

  expect_s3_class(uploadee, "dribble")
  expect_identical(nrow(uploadee), 1L)
  expect_identical(uploadee$drive_resource[[1]]$parents[[1]], destination$id)
})

test_that("drive_upload() accepts body metadata via ...", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(me_("DESCRIPTION"))

  uploadee <- drive_upload(
    system.file("DESCRIPTION"),
    name = me_("DESCRIPTION"),
    starred = TRUE
  )
  expect_s3_class(uploadee, "dribble")
  expect_identical(nrow(uploadee), 1L)
  expect_true(uploadee$drive_resource[[1]]$starred)
})
