context("Search files")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-search")


run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del_ids <- drive_search(pattern = paste(nm_(c("foo","this-should-not-exist"))))$id
    if (!is.null(del_ids)) {
      del_files <- purrr::map(del_ids, drive_file)
      del <- purrr::map(del_files, drive_delete, verbose = FALSE)
    }
  }

  ## test that it finds at least a folder
  drive_mkdir(nm_("foo"), verbose = FALSE)
}

test_that("drive_search() passes q correctly", {
  skip_on_appveyor()
  skip_on_travis()

  ## this should find at least 1 folder (foo), and all files found should
  ## be folders

  expect_true(all(drive_search(q = "mimeType='application/vnd.google-apps.folder'")$type == "folder"))

})

test_that("drive_search() finds created file correctly", {
  skip_on_appveyor()
  skip_on_travis()

  ## this should be able to find the folder we created, foo-TEST-drive-search

  expect_identical(drive_search(pattern = nm_("foo"))$name, nm_("foo"))

})

test_that("drive_search() gives sensible message if a file does not exist", {
  skip_on_appveyor()
  skip_on_travis()

  ## this should be able to find the folder we created, foo-TEST-drive-search

  expect_message(drive_search(pattern = nm_("this-should-not-exist")),
                 "No file names match the pattern")

})
