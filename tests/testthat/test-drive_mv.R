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

  name_1 <- me_("DESC")
  name_2 <- me_("DESC-renamed")
  on.exit(drive_rm(name_2))
  local_drive_loud()

  file <- drive_upload(system.file("DESCRIPTION"), name_1)

  drive_mv_message <- capture.output(
    file <- drive_mv(file, name = name_2),
    type = "message"
  )
  drive_mv_message <- sub(name_1, "{name_1}", drive_mv_message, perl = TRUE)
  drive_mv_message <- sub(name_2, "{name_2}", drive_mv_message, perl = TRUE)
  expect_snapshot(
    writeLines(drive_mv_message)
  )

  expect_s3_class(file, "dribble")
  expect_identical(nrow(file), 1L)
})

test_that("drive_mv() can move a file into a folder given as path", {
  skip_if_no_token()
  skip_if_offline()

  mv_name <- me_("DESC")
  on.exit(drive_rm(mv_name))
  local_drive_loud()

  mv_file <- drive_upload(system.file("DESCRIPTION"), mv_name)

  ## path is detected as folder (must have trailing slash)
  drive_mv_message <- capture.output(
    mv_file <- drive_mv(mv_file, paste0(nm_("move-files-into-me"), "/")),
    type = "message"
  )
  drive_mv_message <- gsub(mv_name, "{mv_name}", drive_mv_message, perl = TRUE)
  expect_snapshot(
    writeLines(drive_mv_message)
  )

  expect_s3_class(mv_file, "dribble")
  expect_identical(nrow(mv_file), 1L)
  destination <- drive_get(nm_("move-files-into-me"))
  expect_identical(mv_file$drive_resource[[1]]$parents[[1]], destination$id)
})

test_that("drive_mv() can move a file into a folder given as dribble", {
  skip_if_no_token()
  skip_if_offline()

  mv_name <- me_("DESC")
  on.exit(drive_rm(mv_name))
  local_drive_loud()

  mv_file <- drive_upload(system.file("DESCRIPTION"), mv_name)
  destination <- drive_get(nm_("move-files-into-me"))

  drive_mv_message <- capture.output(
    mv_file <- drive_mv(mv_file, destination),
    type = "message"
  )
  drive_mv_message <- gsub(mv_name, "{mv_name}", drive_mv_message, perl = TRUE)
  expect_snapshot(
    writeLines(drive_mv_message)
  )

  expect_s3_class(mv_file, "dribble")
  expect_identical(nrow(mv_file), 1L)
  expect_identical(mv_file$drive_resource[[1]]$parents[[1]], destination$id)
})

test_that("drive_mv() can rename and move, using `path` and `name`", {
  skip_if_no_token()
  skip_if_offline()

  name_1 <- me_("DESC")
  name_2 <- me_("DESC-renamed")
  on.exit(drive_rm(name_2))
  local_drive_loud()

  mv_file <- drive_upload(system.file("DESCRIPTION"), name_1)

  drive_mv_message <- capture.output(
    mv_file <- drive_mv(mv_file, nm_("move-files-into-me"), name_2),
    type = "message"
  )
  drive_mv_message <- gsub(name_1, "{name_1}", drive_mv_message, perl = TRUE)
  drive_mv_message <- gsub(name_2, "{name_2}", drive_mv_message, perl = TRUE)
  expect_snapshot(
    writeLines(drive_mv_message)
  )

  expect_s3_class(mv_file, "dribble")
  expect_identical(nrow(mv_file), 1L)
})

test_that("drive_mv() can rename and move, using `path` only", {
  skip_if_no_token()
  skip_if_offline()

  name_1 <- me_("DESC")
  name_2 <- me_("DESC-renamed")
  on.exit(drive_rm(name_2))
  local_drive_loud()

  mv_file <- drive_upload(system.file("DESCRIPTION"), name_1)

  drive_mv_message <- capture.output(
    mv_file <- drive_mv(
      mv_file,
      file.path(nm_("move-files-into-me"), name_2)
    ),
    type = "message"
  )
  drive_mv_message <- gsub(name_1, "{name_1}", drive_mv_message, perl = TRUE)
  drive_mv_message <- gsub(name_2, "{name_2}", drive_mv_message, perl = TRUE)
  expect_snapshot(
    writeLines(drive_mv_message)
  )

  expect_s3_class(mv_file, "dribble")
  expect_identical(nrow(mv_file), 1L)
})
