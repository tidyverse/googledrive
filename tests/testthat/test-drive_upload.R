context("Upload files")

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
  drive_mkdir(nm_("upload-into-me-too"))
}

# ---- tests ----
test_that("drive_upload() detects non-existent file", {
  expect_error(drive_upload("no-such-file"), "File does not exist")
})

test_that("drive_upload() places file in non-root folder, with new name", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("DESCRIPTION")))

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
  on.exit(drive_rm(me_("DESCRIPTION")))

  uploadee <- drive_upload(
    system.file("DESCRIPTION"),
    name = me_("DESCRIPTION"),
    starred = TRUE
  )
  expect_s3_class(uploadee, "dribble")
  expect_identical(nrow(uploadee), 1L)
  expect_true(uploadee$drive_resource[[1]]$starred)

})

test_that("drive_upload() errors if given both 'path' and 'parents'", {
  skip_if_no_token()
  skip_if_offline()

  destination <- drive_get(nm_("upload-into-me"))
  destination2 <- drive_get(nm_("upload-into-me-too"))

  expect_error({
    uploadee <- drive_upload(
    system.file("DESCRIPTION"),
    path = destination,
    name = me_("DESCRIPTION"),
    parents = destination2$id
    )},
    "You have specified parent folders via both 'path' and 'parents'"
  )
})

## Test of multiple parents - it seems this action in particular lags (or at least
## was lagging when I was working on it), so I have removed it as a formal test.
# test_that("drive_upload() can upload into multiple `parents`", {
#   skip_if_no_token()
#   skip_if_offline()
#   on.exit(drive_rm(me_("DESCRIPTION")))
#
#   destination <- drive_get(nm_("upload-into-me"))
#   destination2 <- drive_get(nm_("upload-into-me-too"))
#
#   uploadee <- drive_upload(
#     system.file("DESCRIPTION"),
#     name = me_("DESCRIPTION"),
#     parents = c(destination$id, destination2$id)
#   )
#
#   expect_s3_class(uploadee, "dribble")
#   expect_identical(nrow(uploadee), 1L)
#   expect_identical(uploadee$drive_resource[[1]]$parents,
#                    list(destination2$id, destination$id))
#
# })

