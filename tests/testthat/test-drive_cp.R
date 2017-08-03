context("Copy files")

# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-cp")
nm_ <- nm_fun("TEST-drive-cp", NULL)

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
  drive_mkdir(nm_("not-unique-folder"))
  drive_mkdir(nm_("not-unique-folder"))
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("i-am-a-file")
  )
}

# ---- tests ----
test_that("drive_cp() can copy file in place", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("i-am-a-file")))

  file <- drive_get(nm_("i-am-a-file"))
  expect_message(
    file_cp <- drive_cp(file, name = me_("i-am-a-file")),
    "File copied"
  )
  expect_identical(file_cp$name, me_("i-am-a-file"))

  ## should have the same parent
  expect_identical(file$drive_resource[[1]]$parents,
                   file_cp$drive_resource[[1]]$parents)
})

test_that("drive_cp() can copy a file into a different folder", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("i-am-a-file")))

  file <- drive_get(nm_("i-am-a-file"))
  folder <- drive_get(nm_("i-am-a-folder"))
  expect_message(
    file_cp <- drive_cp(file, path = folder, name = me_("i-am-a-file")),
    "File copied"
  )
  expect_identical(file_cp$name, me_("i-am-a-file"))

  ## should have folder as parent
  expect_identical(file_cp$drive_resource[[1]]$parents[[1]], folder$id)
})

test_that("drive_cp() doesn't tolerate ambiguity in `path`", {
  skip_if_no_token()
  skip_if_offline()

  file <- drive_get(nm_("i-am-a-file"))
  ## `path` lacks trailing slash, so ambiguous if it's parent folder or
  ## folder + name
  expect_error(
    file_cp <- drive_cp(file, nm_("i-am-a-folder")),
    "Unclear if `path` specifies parent folder or full path"
  )
})

test_that("drive_cp() errors if asked to copy a folder", {
  skip_if_no_token()
  skip_if_offline()

  expect_error(
    drive_cp(nm_("i-am-a-folder")),
    "The Drive API does not copy folders"
  )
})

test_that("drive_cp() takes name, assumes path is folder if both are specified", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(nm_("file-name")))

  ## if given `path` and `name`, assumes `path` is a folder
  expect_message(
    file_cp <- drive_cp(
      nm_("i-am-a-file"),
      path = nm_("i-am-a-folder"),
      name = me_("file-name")
    ),
    "File copied"
  )
  expect_identical(file_cp$name, me_("file-name"))

  ## if `path` is not a folder, will error
  expect_error(
    file_cp <- drive_cp(
      nm_("i-am-a-file"),
      nm_("file-name"),
      nm_("file-name")
    )
  )

  ## if `path` identifies multiple files, it will error
  expect_error(
    file_cp <- drive_cp(
      nm_("i-am-a-file"),
      paste0(nm_("not-unique-folder"), "/")
    ),
    "Requested parent folder identifies multiple files"
  )
})
