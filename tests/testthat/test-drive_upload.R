context("Upload files")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-upload")

clean <- FALSE

if (clean) {
  del <- drive_delete(c(nm_("foo"), nm_("bar")))
}

test_that("drive_upload() detects non-existant file", {
  skip_on_appveyor()
  skip_on_travis()

  #the file should be a file that exists
  input <- "this should not work"
  expect_error(drive_upload(from = input), "File does not exist")
})

test_that("drive_upload() places file in the correct folder", {
  skip_on_appveyor()
  skip_on_travis()

  foo <- drive_mkdir(nm_("foo"))

  ## foo
  ## |- bar
  bar <- drive_upload(system.file("DESCRIPTION"), name = nm_("bar"), folder = nm_("foo"))
  expect_identical(bar$files_resource[[1]]$parents[[1]], foo$id)

  ## clean up
  drive_delete(nm_("foo"))
})
