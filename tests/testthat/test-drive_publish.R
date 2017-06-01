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
    del_ids <- drive_search(pattern = paste(c(nm_("chickwts_txt"),
                                              nm_("chickwts_gdoc")),
                                            collapse = "|"))$id
    if (!is.null(del_ids)) {
      del_files <- purrr::map(drive_id(del_ids), drive_get)
      del <- purrr::map(del_files, drive_delete)
    }
  }
  write.table(chickwts, "chickwts.txt")
  drive_upload("chickwts.txt",
               up_name = nm_("chickwts_gdoc"),
               type = "document",
               verbose = FALSE)

  drive_upload("chickwts.txt",
               up_name = nm_("chickwts_txt"),
               verbose = FALSE)


  rm <- unlink("chickwts.txt")
}


test_that("drive_publish doesn't explicitly fail", {

  skip_on_appveyor()
  skip_on_travis()

  drive_chickwts <- drive_get(drive_id(drive_path(nm_("chickwts_gdoc"))$id))

  ## since we haven't checked the publication status,
  ## this should be NULL
  expect_equal(drive_chickwts$files_resource[[1]]$publish, NULL)

  drive_chickwts <- drive_publish(drive_chickwts)

  ## the published column should be TRUE
  expect_true(drive_chickwts$publish[[1]]$published)

  ## let's unpublish it

  drive_chickwts <- drive_unpublish(drive_chickwts)

  ## now this sould be false
  expect_false(drive_chickwts$publish[[1]]$published)
})

test_that("drive_publish fails if the file input is not a Google Drive type",{

  skip_on_appveyor()
  skip_on_travis()

  drive_chickwts <- drive_get(drive_id(drive_path(nm_("chickwts_txt"))$id))

  expect_error(drive_publish(drive_chickwts, verbose = FALSE),
               "Only Google Drive files can be published."
  )
})

