# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-mv")
nm_ <- nm_fun("TEST-drive-mv", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("move-files-into-me"),
    nm_("DESC"),
    nm_("DESC-renamed")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("move-files-into-me"))
}

# ---- tests ----
test_that("drive_mv() can rename file", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("DESC-renamed")))

  renamee <- drive_upload(
    system.file("DESCRIPTION"),
    me_("DESC"),
    verbose = FALSE
  )
  # TODO: make this a snapshot test, once I have verbosity control
  out <- drive_mv(renamee, name = me_("DESC-renamed"))
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
})

test_that("drive_mv() can move a file into a folder given as path", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("DESC")))

  movee <- drive_upload(system.file("DESCRIPTION"), me_("DESC"))

  ## path is detected as folder (must have trailing slash)
  # TODO: make this a snapshot test, once I have verbosity control
  out <- drive_mv(movee, paste0(nm_("move-files-into-me"), "/"))
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
  destination <- drive_get(nm_("move-files-into-me"))
  expect_identical(out$drive_resource[[1]]$parents[[1]], destination$id)
})

test_that("drive_mv() can move a file into a folder given as dribble", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("DESC")))

  movee <- drive_upload(system.file("DESCRIPTION"), me_("DESC"))

  destination <- drive_get(nm_("move-files-into-me"))
  # TODO: make this a snapshot test, once I have verbosity control
  out <- drive_mv(movee, destination)
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
  expect_identical(out$drive_resource[[1]]$parents[[1]], destination$id)
})

test_that("drive_mv() can rename and move, using `path` and `name`", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("DESC-renamed")))

  movee <- drive_upload(system.file("DESCRIPTION"), me_("DESC"))

  # TODO: make this a snapshot test, once I have verbosity control
  out <- drive_mv(movee, nm_("move-files-into-me"), me_("DESC-renamed"))
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
})

test_that("drive_mv() can rename and move, using `path` only", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("DESC-renamed")))

  movee <- drive_upload(system.file("DESCRIPTION"), me_("DESC"))

  # TODO: make this a snapshot test, once I have verbosity control
  out <- drive_mv(
    movee,
    file.path(nm_("move-files-into-me"), me_("DESC-renamed"))
  )
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
})
