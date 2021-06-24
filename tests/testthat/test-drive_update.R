# ---- nm_fun ----
me_ <- nm_fun("TEST-drive_update")
nm_ <- nm_fun("TEST-drive_update", user_run = FALSE)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("update-fodder"),
    nm_("not-unique"),
    nm_("does-not-exist"),
    nm_("upload-into-me")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_upload(system.file("DESCRIPTION"), nm_("update-fodder"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
  drive_mkdir(nm_("upload-into-me"))
}

# ---- tests ----
test_that("drive_update() errors if local media does not exist", {
  expect_snapshot(drive_update(dribble(), "nope123"), error = TRUE)
})

test_that("drive_update() informatively errors if the path does not exist", {
  skip_if_no_token()
  skip_if_offline()
  expect_snapshot(
    drive_update(nm_("does-not-exist"), system.file("DESCRIPTION")),
    error = TRUE
  )
})

test_that("drive_update() informatively errors if the path is not unique", {
  skip_if_no_token()
  skip_if_offline()
  expect_snapshot(
    drive_update(nm_("not-unique"), system.file("DESCRIPTION")),
    error = TRUE
  )
})

test_that("no op if no media, no metadata", {
  skip_if_no_token()
  skip_if_offline()

  local_drive_loud_and_wide()
  expect_snapshot(
    out <- drive_update(nm_("update-fodder")),
  )
  expect_dribble(out)
})

test_that("drive_update() can update metadata only", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(me_("update-me"))

  updatee <- drive_cp(nm_("update-fodder"), name = me_("update-me"))
  out <- drive_update(updatee, starred = TRUE) %>% promote("starred")
  expect_true(out$starred)
})

test_that("drive_update() uses multipart request to update media + metadata", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(c(me_("update-me"), me_("update-me-new")))

  updatee <- drive_cp(nm_("update-fodder"), name = me_("update-me"))
  tmp <- tempfile()
  now <- as.character(Sys.time())
  write_utf8(now, tmp)

  out <- drive_update(updatee, media = tmp, name = me_("update-me-new"))
  expect_identical(out$id, updatee$id)
  drive_download(updatee, tmp, overwrite = TRUE)
  now_out <- read_utf8(tmp)
  expect_identical(now, now_out)
  expect_identical(out$name, me_("update-me-new"))
})

test_that("drive_update() can add a parent", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(me_("DESCRIPTION"))

  uploadee <- drive_upload(
    system.file("DESCRIPTION"),
    name = me_("DESCRIPTION"),
    starred = TRUE
  )
  orig_parents <- unlist(pluck(uploadee, "drive_resource", 1, "parents"))

  folder <- drive_get(nm_("upload-into-me"))
  updatee <- drive_update(uploadee, addParents = as_id(folder))
  new_parents <- unlist(pluck(updatee, "drive_resource", 1, "parents"))

  expect_identical(
    setdiff(new_parents, orig_parents),
    folder$id
  )
})
