# ---- nm_fun ----
me_ <- nm_fun("TEST-drive_upload")
nm_ <- nm_fun("TEST-drive_upload", user_run = FALSE)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("upload-into-me"),
    nm_("upload-via-folder-shortcut"),
    nm_("DESCRIPTION")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("upload-into-me"))
  shortcut_create(nm_("upload-into-me"), name = nm_("upload-via-folder-shortcut"))
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

  expect_dribble(uploadee)
  expect_identical(nrow(uploadee), 1L)
  expect_identical(drive_reveal(uploadee, "parent")$id_parent, destination$id)
})

test_that("drive_upload() can place file via folder-shortcut", {
  skip_if_no_token()
  skip_if_offline()

  upload_name <- me_("upload-via-shortcut-folder")
  defer_drive_rm(upload_name)

  target_parent <- drive_get(nm_("upload-into-me"))
  shortcut <- nm_("upload-via-folder-shortcut")

  uploadee <- drive_upload(
    system.file("DESCRIPTION"),
    path = shortcut,
    name = upload_name
  )
  expect_equal(drive_reveal(uploadee, "parent")$id_parent, target_parent$id)
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
  expect_dribble(uploadee)
  expect_identical(nrow(uploadee), 1L)
  expect_true(uploadee$drive_resource[[1]]$starred)
})

# https://github.com/tidyverse/googledrive/pull/342
test_that("drive_upload() does not mangle name with multi-byte characters", {
  skip_if_no_token()
  skip_if_offline()

  # KATAKANA LETTERS MA RU TI
  tricky_bit <- "\u30DE\u30EB\u30C1"
  filename_1 <- me_(paste0("multibyte-chars-1-", tricky_bit))
  defer_drive_rm(filename_1)

  file_1 <- drive_upload(
    drive_example_local("chicken.csv"),
    path = filename_1,
    type = "spreadsheet"
  )
  expect_equal(charToRaw(file_1$name), charToRaw(filename_1))

  # TODO: when I was here, I hoped to also handle the case where the user
  # allows the Drive file name to come from its local name and *that*
  # name contains CJK characters
  # Ultimately I concluded that curl (the R package) doesn't really support
  # this currently, so I'm leaving it alone for now.
  # Leaving these notes, in case I ever come through here again.
  # https://github.com/jeroen/curl/issues/182
  # https://github.com/curl/curl/issues/345
  # filename_2 <- me_(paste0("multibyte-chars-2-", tricky_bit))
  # filename_2 <- file.path(tempdir(), filename_2)
  # file.copy(drive_example_local("chicken.csv"), filename_2)
  # expect_true(file.exists(filename_2))
  # file_2 <- drive_upload(media = filename_2)
  # expect_equal(charToRaw(file_2$name), charToRaw(filename_2))
})
