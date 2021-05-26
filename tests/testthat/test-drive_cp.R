# ---- nm_fun ----
me_ <- nm_fun("TEST-drive_cp")
nm_ <- nm_fun("TEST-drive_cp", user_run = FALSE)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("i-am-a-folder"),
    nm_("not-unique-folder"),
    nm_("i-am-a-file")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("i-am-a-folder"))
  drive_mkdir(name = nm_("not-unique-folder"), path = as_id(googledrive:::root_id()))
  drive_mkdir(name = nm_("not-unique-folder"), path = as_id(googledrive:::root_id()))
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("i-am-a-file")
  )
}

# ---- tests ----
test_that("drive_cp() can copy file in place", {
  skip_if_no_token()
  skip_if_offline()

  cp_name <- me_("i-am-a-file")
  defer_drive_rm(cp_name)

  file <- drive_get(nm_("i-am-a-file"))

  local_drive_loud_and_wide()
  drive_cp_message <- capture.output(
    cp_file <- drive_cp(file, name = cp_name),
    type = "message"
  )
  drive_cp_message <- drive_cp_message %>%
    scrub_filepath(cp_name) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_cp_message)
  )

  expect_identical(cp_file$name, cp_name)

  ## should have the same parent
  expect_identical(
    file$drive_resource[[1]]$parents,
    cp_file$drive_resource[[1]]$parents
  )
})

test_that("drive_cp() can copy a file into a different folder", {
  skip_if_no_token()
  skip_if_offline()

  cp_name <- me_("i-am-a-file")
  defer_drive_rm(cp_name)

  file <- drive_get(nm_("i-am-a-file"))
  folder <- drive_get(nm_("i-am-a-folder"))

  local_drive_loud_and_wide(200)
  drive_cp_message <- capture.output(
    cp_file <- drive_cp(file, path = folder, name = cp_name),
    type = "message"
  )
  drive_cp_message <- drive_cp_message %>%
    scrub_filepath(cp_name) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_cp_message)
  )
  expect_identical(cp_file$name, cp_name)

  # should have folder as parent
  file <- drive_reveal(cp_file, "parent")
  expect_identical(file$id_parent, folder$id)
})

test_that("drive_cp() doesn't tolerate ambiguity in `path`", {
  skip_if_no_token()
  skip_if_offline()

  file <- drive_get(nm_("i-am-a-file"))
  # `path` lacks trailing slash, so ambiguous if it's parent folder or
  # folder + name
  expect_snapshot(
    drive_cp(file, nm_("i-am-a-folder")),
    error = TRUE
  )
})

test_that("drive_cp() errors if asked to copy a folder", {
  skip_if_no_token()
  skip_if_offline()

  expect_snapshot(
    drive_cp(nm_("i-am-a-folder")),
    error = TRUE
  )
})

test_that("drive_cp() takes name, assumes path is folder if both are specified", {
  skip_if_no_token()
  skip_if_offline()

  cp_name <- me_("file-name")
  defer_drive_rm(cp_name)
  local_drive_loud_and_wide(200)

  # if given `path` and `name`, assumes `path` is a folder
  # the message capture trick is necessary because cp_name includes {user}
  drive_cp_message <- capture.output(
    file_cp <- drive_cp(
      nm_("i-am-a-file"),
      path = nm_("i-am-a-folder"),
      name = cp_name
    ),
    type = "message"
  )
  drive_cp_message <- drive_cp_message %>%
    scrub_filepath(cp_name) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_cp_message)
  )

  expect_identical(file_cp$name, me_("file-name"))

  # error if `path` is not a folder
  expect_snapshot(
    file_cp <- drive_cp(
      nm_("i-am-a-file"),
      path = nm_("file-name"),
      name = nm_("file-name")
    ),
    error = TRUE
  )

  # error if `path` doesn't uniquely identify one folder/shared drive
  expect_snapshot(
    file_cp <- drive_cp(
      nm_("i-am-a-file"),
      append_slash(nm_("not-unique-folder"))
    ),
    error = TRUE
  )
})
