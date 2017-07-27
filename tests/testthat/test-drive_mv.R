context("Move files")

# ---- nm_fun ----
nm_ <- nm_fun("-TEST-drive-mv")

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
  on.exit(drive_rm(nm_("DESC-renamed")))

  renamee <- drive_upload(
    system.file("DESCRIPTION"),
    nm_("DESC"),
    verbose = FALSE
  )
  expect_message(
    out <- drive_mv(renamee, name = nm_("DESC-renamed")),
    "File renamed"
  )
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
})

test_that("drive_mv() can move a file into a folder given as path", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(nm_("DESC")))

  movee <- drive_upload(
    system.file("DESCRIPTION"),
    nm_("DESC"),
    verbose = FALSE
  )

  ## path is detected as folder (must have trailing slash)
  expect_message(
    out <- drive_mv(movee, paste0(nm_("move-files-into-me"), "/")),
    "File moved"
  )
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
  destination <- drive_get(nm_("move-files-into-me"))
  expect_identical(out$files_resource[[1]]$parents[[1]], destination$id)
})

test_that("drive_mv() can move a file into a folder given as dribble", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(nm_("DESC")))

  movee <- drive_upload(
    system.file("DESCRIPTION"),
    nm_("DESC"),
    verbose = FALSE
  )

  destination <- drive_get(nm_("move-files-into-me"))
  expect_message(
    out <- drive_mv(movee, destination),
    "File moved"
  )
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
  expect_identical(out$files_resource[[1]]$parents[[1]], destination$id)
})

test_that("drive_mv() can rename and move, using `path` and `name`", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(nm_("DESC-renamed")))

  movee <- drive_upload(
    system.file("DESCRIPTION"),
    nm_("DESC"),
    verbose = FALSE
  )

  expect_message(
    out <- drive_mv(movee, nm_("move-files-into-me"), nm_("DESC-renamed")),
    "File renamed and moved"
  )
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
})

test_that("drive_mv() can rename and move, using `path` only", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(nm_("DESC-renamed")))

  movee <- drive_upload(
    system.file("DESCRIPTION"),
    nm_("DESC"),
    verbose = FALSE
  )

  expect_message(
    out <- drive_mv(
      movee,
      file.path(nm_("move-files-into-me"), nm_("DESC-renamed"))
    ),
    "File renamed and moved"
  )
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
})
