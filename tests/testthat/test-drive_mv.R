# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-mv")
nm_ <- nm_fun("TEST-drive-mv", user_run = FALSE)

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
  defer_drive_rm(name_2)

  file <- drive_upload(system.file("DESCRIPTION"), name_1)

  local_drive_loud_and_wide()
  drive_mv_message <- capture.output(
    file <- drive_mv(file, name = name_2),
    type = "message"
  )
  drive_mv_message <- drive_mv_message %>%
    scrub_filepath(name_1) %>%
    scrub_filepath(name_2) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_mv_message)
  )

  expect_dribble(file)
  expect_identical(nrow(file), 1L)
})

test_that("drive_mv() can move a file into a folder given as path", {
  skip_if_no_token()
  skip_if_offline()

  mv_name <- me_("DESC")
  defer_drive_rm(mv_name)

  mv_file <- drive_upload(system.file("DESCRIPTION"), mv_name)

  local_drive_loud_and_wide(130)
  # path is detected as folder (must have trailing slash)
  drive_mv_message <- capture.output(
    mv_file <- drive_mv(mv_file, paste0(nm_("move-files-into-me"), "/")),
    type = "message"
  )
  drive_mv_message <- drive_mv_message %>%
    scrub_filepath(mv_name) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_mv_message)
  )

  expect_dribble(mv_file)
  expect_identical(nrow(mv_file), 1L)
  with_drive_quiet(
    destination <- drive_get(nm_("move-files-into-me"))
  )
  mv_file <- drive_reveal(mv_file, "parent")
  expect_equal(mv_file$id_parent, destination$id)
})

test_that("drive_mv() can move a file into a folder given as dribble", {
  skip_if_no_token()
  skip_if_offline()

  mv_name <- me_("DESC")
  defer_drive_rm(mv_name)

  mv_file <- drive_upload(system.file("DESCRIPTION"), mv_name)
  destination <- drive_get(nm_("move-files-into-me"))

  local_drive_loud_and_wide(130)
  drive_mv_message <- capture.output(
    mv_file <- drive_mv(mv_file, destination),
    type = "message"
  )
  drive_mv_message <- drive_mv_message %>%
    scrub_filepath(mv_name) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_mv_message)
  )

  expect_dribble(mv_file)
  expect_identical(nrow(mv_file), 1L)
  expect_identical(mv_file$drive_resource[[1]]$parents[[1]], destination$id)
})

test_that("drive_mv() can rename and move, using `path` and `name`", {
  skip_if_no_token()
  skip_if_offline()

  name_1 <- me_("DESC")
  name_2 <- me_("DESC-renamed")
  defer_drive_rm(name_2)

  mv_file <- drive_upload(system.file("DESCRIPTION"), name_1)

  local_drive_loud_and_wide(130)
  drive_mv_message <- capture.output(
    mv_file <- drive_mv(mv_file, nm_("move-files-into-me"), name_2),
    type = "message"
  )
  drive_mv_message <- drive_mv_message %>%
    scrub_filepath(name_1) %>%
    scrub_filepath(name_2) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_mv_message)
  )

  expect_dribble(mv_file)
  expect_identical(nrow(mv_file), 1L)
})

test_that("drive_mv() can rename and move, using `path` only", {
  skip_if_no_token()
  skip_if_offline()

  name_1 <- me_("DESC")
  name_2 <- me_("DESC-renamed")
  defer_drive_rm(name_2)

  mv_file <- drive_upload(system.file("DESCRIPTION"), name_1)

  local_drive_loud_and_wide(130)
  drive_mv_message <- capture.output(
    mv_file <- drive_mv(
      mv_file,
      file.path(nm_("move-files-into-me"), name_2)
    ),
    type = "message"
  )
  drive_mv_message <- drive_mv_message %>%
    scrub_filepath(name_1) %>%
    scrub_filepath(name_2) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_mv_message)
  )

  expect_dribble(mv_file)
  expect_identical(nrow(mv_file), 1L)
})
