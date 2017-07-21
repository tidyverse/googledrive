context("Copy files")

nm_ <- nm_fun("-TEST-drive-cp")

## clean
if (FALSE) {
  del <- drive_rm(c(
    nm_("i-am-a-folder"),
    nm_("not-unique-folder"),
    nm_("i-am-a-file")
  ), verbose = FALSE)
}

## setup
if (FALSE) {
  drive_mkdir(nm_("i-am-a-folder"))
  drive_mkdir(nm_("not-unique-folder"))
  drive_mkdir(nm_("not-unique-folder"))
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("i-am-a-file"),
    verbose = FALSE
  )
}

test_that("drive_cp() can copy file in place", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  on.exit(drive_rm(paste("Copy of", nm_("i-am-a-file"))))

  file <- drive_get(nm_("i-am-a-file"))
  expect_message(
    file_cp <- drive_cp(file),
    "File copied"
  )
  expect_identical(file_cp$name, paste("Copy of", nm_("i-am-a-file")))

  ## should have the same parent
  expect_identical(file$files_resource[[1]]$parents,
                   file_cp$files_resource[[1]]$parents)
})

test_that("drive_cp() can copy a file into a different folder", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  on.exit(drive_rm(paste("Copy of", nm_("i-am-a-file"))))

  file <- drive_get(nm_("i-am-a-file"))
  folder <- drive_get(nm_("i-am-a-folder"))
  expect_message(
    file_cp <- drive_cp(file, folder),
    "File copied"
  )
  expect_identical(file_cp$name, paste("Copy of", nm_("i-am-a-file")))

  ## should have folder as parent
  expect_identical(file_cp$files_resource[[1]]$parents[[1]], folder$id)
})

test_that("drive_cp() elects to copy into a folder vs onto file of same name", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  on.exit(drive_rm(paste("Copy of", nm_("i-am-a-file"))))

  file <- drive_get(nm_("i-am-a-file"))
  ## does drive_cp() detect that path is a folder, despite lack of trailing
  ## slash? No.
  expect_error(
    file_cp <- drive_cp(file, nm_("i-am-a-folder")),
    "Unclear if `path` specifies parent folder or full path"
  )

  ## does drive_cp() work with trailing slash? Yes.
  expect_message(
    file_cp <- drive_cp(file, paste0(nm_("i-am-a-folder"), "/")),
    "File copied"
  )
  ## should have folder as parent
  folder <- drive_get(nm_("i-am-a-folder"))
  expect_identical(file_cp$files_resource[[1]]$parents[[1]], folder$id)
})

test_that("drive_cp() errors if asked to copy a folder", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  expect_error(
    drive_cp(nm_("i-am-a-folder")),
    "The Drive API does not copy folders"
  )
})

test_that("drive_cp() takes name, assumes path is folder if both are specified", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  on.exit(drive_rm(nm_("file-name")))

  ## if given `path` and `name`, assumes `path` is a folder
  expect_message(
    file_cp <- drive_cp(nm_("i-am-a-file"), nm_("i-am-a-folder"), nm_("file-name")),
    "File copied"
  )
  expect_identical(file_cp$name, nm_("file-name"))

  ## if `path` is not a folder, will copy to parent of file
  expect_message(
    file_cp <- drive_cp(nm_("i-am-a-file"), nm_("file-name"), nm_("file-name")),
    "Defaulting to save in the parent of `file`"
  )

  ## if `path` identifies multiple files, it will error
  expect_error(
    file_cp <- drive_cp(nm_("i-am-a-file"), paste0(nm_("not-unique-folder"), "/")),
    "Requested parent folder identifies multiple files"
  )
})
