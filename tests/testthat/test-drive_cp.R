context("Copy files")


## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-cp")

run <- FALSE
clean <- FALSE
if (run) {
  if (clean) {
    del <- drive_delete(c(
      nm_("i-am-a-folder"),
      nm_("non-google-file"),
      nm_("google-doc")
    ), verbose = FALSE)
  }

  drive_mkdir(nm_("i-am-a-folder"))
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("non-google-file"),
    verbose = FALSE
  )
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("google-doc"),
    type = "document",
    verbose = FALSE
  )

}

test_that("drive_cp() can copy a non-Google file", {
  skip_on_appveyor()
  skip_on_travis()
  on.exit(drive_delete(paste("Copy of", nm_("non-google-file"))))

  non_goog <- drive_path(nm_("non-google-file"))
  expect_message(
    non_goog_cp <- drive_cp(nm_("non-google-file")),
    "File copied"
  )
  expect_identical(non_goog_cp$name, paste("Copy of", nm_("non-google-file")))

  ## should have the same parent
  expect_identical(non_goog$files_resource[[1]]$parents,
                   non_goog_cp$files_resource[[1]]$parents)
})

test_that("drive_cp() can copy a Google file", {
  skip_on_appveyor()
  skip_on_travis()
  on.exit(drive_delete(paste("Copy of", nm_("google-doc"))))

  gdoc <- drive_path(nm_("google-doc"))
  expect_message(gdoc_cp <- drive_cp(nm_("google-doc")), "File copied")
  expect_identical(gdoc_cp$name, paste("Copy of", nm_("google-doc")))

  ## should have the same parent
  expect_identical(gdoc$files_resource[[1]]$parents,
                   gdoc_cp$files_resource[[1]]$parents)
})

test_that("drive_cp() errors if given a folder", {
  skip_on_appveyor()
  skip_on_travis()

  expect_error(
    drive_cp(nm_("i-am-a-folder")),
    "The Drive API does not copy folders"
  )
})
