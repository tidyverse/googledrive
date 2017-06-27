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
    del <- drive_delete(c(nm_("foo"), nm_("bar"), nm_("this-should-not-exist")),
                        verbose = FALSE)
  }
  drive_upload(system.file("DESCRIPTION"), nm_("foo"), verbose = FALSE)
  drive_upload(system.file("DESCRIPTION"),
               nm_("bar"),
               type = "document",
               verbose = FALSE)
}

test_that("drive_download() properly downloads", {
  skip_on_appveyor()
  skip_on_travis()
  expect_message(drive_download(file = nm_("foo"), out_path = "description.txt"),
                 "File downloaded from Google Drive:")
  expect_true(file.exists("description.txt"))
  on.exit(unlink("description.txt"))
})

test_that("drive_download() properly errors if file does not exist on Drive", {
  skip_on_appveyor()
  skip_on_travis()
  expect_error(drive_download(file = nm_("this-should-not-exist"),
                              out_path = "empty.txt"),
               "Input does not hold exactly one Drive file")
})

test_that("drive_download() properly converts with type argument", {
  skip_on_appveyor()
  skip_on_travis()

  expect_message(drive_download(file = nm_("bar"), type = "docx"),
                 "File downloaded from Google Drive:"
                 )
  nm <- paste0(nm_("bar"), ".docx")
  expect_true(file.exists(nm))
  on.exit(unlink(nm))
})

test_that("drive_download() properly converts with out_path argument", {
  skip_on_appveyor()
  skip_on_travis()

  nm <- paste0(nm_("bar"), ".docx")
  expect_message(drive_download(file = nm_("bar"), out_path = nm),
                 "File downloaded from Google Drive:"
                 )
  expect_true(file.exists(nm))
  on.exit(unlink(nm))
})

test_that("drive_download() properly converts with defaults", {
  skip_on_appveyor()
  skip_on_travis()

  nm <- paste0(nm_("bar"), ".docx")
  expect_message(drive_download(file = nm_("bar")),
                 "File downloaded from Google Drive:"
                 )
  expect_true(file.exists(nm))
  on.exit(unlink(nm))
})
