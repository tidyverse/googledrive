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
      del_files <- purrr::map(del_ids, drive_file)
      del <- purrr::map(del_files, drive_delete, verbose = FALSE)
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

  drive_chickwts <- drive_file(drive_path(nm_("chickwts_gdoc"))$id)

  ## since we haven't checked the publication status,
  ## this should be NULL
  expect_equal(drive_chickwts$publish, NULL)

  drive_chickwts <- drive_publish(drive_chickwts)

  ## the published column should be TRUE
  expect_true(drive_chickwts$publish$published)

  ## let's unpublish it

  drive_chickwts <- drive_publish(drive_chickwts, publish = FALSE)

  ## now this sould be false
  expect_false(drive_chickwts$publish$published)
})

test_that("drive_publish fails if the file input is not a Google Drive type",{

  skip_on_appveyor()
  skip_on_travis()

  drive_chickwts <- drive_file(drive_path(nm_("chickwts_txt"))$id)

  expect_error(drive_publish(drive_chickwts, verbose = FALSE),
               sprintf("Only Google Drive files need to be published. \nYour file is of type: %s \nCheck out drive_share() to change sharing permissions.",
                       drive_chickwts$type),
               fixed = TRUE
  )
})

