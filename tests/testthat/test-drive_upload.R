context("Upload files")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-upload")

## clean
if (FALSE) {
  del <- drive_delete(c(
    nm_("upload-into-me"),
    nm_("DESCRIPTION")
  ))
}

## setup
if (FALSE) {
  drive_mkdir(nm_("upload-into-me"))
}

test_that("drive_upload() detects non-existent file", {
  expect_error(drive_upload("no-such-file"), "File does not exist")
})

test_that("drive_upload() places file in non-root folder, with new name", {
  skip_on_appveyor()
  skip_on_travis()
  on.exit(drive_delete(nm_("DESCRIPTION")))

  destination <- drive_path(nm_("upload-into-me"))
  uploadee <- drive_upload(
    system.file("DESCRIPTION"),
    path = destination,
    name = nm_("DESCRIPTION")
  )

  expect_s3_class(uploadee, "dribble")
  expect_identical(nrow(uploadee), 1L)
  expect_identical(uploadee$files_resource[[1]]$parents[[1]], destination$id)
})
