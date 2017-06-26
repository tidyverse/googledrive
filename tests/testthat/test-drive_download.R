context("Download files")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-download")


run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del <- drive_delete(c(nm_("foo"), nm_("this-should-not-exist")),
                        verbose = FALSE)
  }
  drive_upload(system.file("DESCRIPTION"), nm_("foo"), verbose = FALSE)
}
test_that("drive_download properly downloads",{
  skip_on_appveyor()
  skip_on_travis()
  expect_message(drive_download(file = nm_("foo"), out_path = "description.txt"),
                 "File downloaded from Google Drive:")
  expect_true(file.exists("description.txt"))
  on.exit(unlink("description.txt"))
})

test_that("drive_download properly errors if file does not exist on Drive",{
  skip_on_appveyor()
  skip_on_travis()
  expect_error(drive_download(file = nm_("this-should-not-exist"),
                              out_path = "empty.txt"),
               "Input does not hold exactly one Drive file")
})
