context("Publish files")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-publish")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del_pths <- c(nm_("chickwts_txt"), nm_("chickwts_gdoc"))
    del <- purrr::map(del_pths, drive_delete, verbose = FALSE)
  }
  write.table(chickwts, "chickwts.txt")
  drive_upload("chickwts.txt",
               name = nm_("chickwts_gdoc"),
               type = "document",
               verbose = FALSE)

  drive_upload("chickwts.txt",
               name = nm_("chickwts_txt"),
               verbose = FALSE)


  rm <- unlink("chickwts.txt")
}


test_that("drive_publish doesn't explicitly fail", {

  skip_on_appveyor()
  skip_on_travis()

  drive_chickwts <- as_dribble(nm_("chickwts_gdoc"))

  ## since we haven't checked the publication status,
  ## this should be NULL
  expect_equal(drive_chickwts$files_resource[[1]]$publish, NULL)

  drive_chickwts <- drive_publish(drive_chickwts)

  ## the published column should be TRUE
  expect_true(drive_chickwts$publish$published)

  ## let's unpublish it

  drive_chickwts <- drive_unpublish(drive_chickwts)

  ## now this sould be false
  expect_false(drive_chickwts$publish$published)
})

test_that("drive_publish fails if the file input is not a Google Drive type", {

  skip_on_appveyor()
  skip_on_travis()

  drive_chickwts <- as_dribble(nm_("chickwts_txt"))

  expect_error(drive_publish(drive_chickwts, verbose = FALSE),
               "Only Google Drive files can be published."
  )
})
