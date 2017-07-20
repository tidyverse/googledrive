context("Publish files")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-publish")

## clean
if (FALSE) {
  del <- drive_rm(c(nm_("foo_pdf"), nm_("foo_doc"), nm_("foo_sheet")),
                  verbose = FALSE)
}
## setup
if (FALSE) {
  drive_upload(R.home('doc/html/about.html'),
               name = nm_("foo_doc"),
               type = "document",
               verbose = FALSE)
  drive_upload(R.home('doc/BioC_mirrors.csv'),
               name = nm_("foo_sheet"),
               type = "spreadsheet",
               verbose = FALSE)
  drive_upload(R.home('doc/html/Rlogo.pdf'),
               name = nm_("foo_pdf"),
               verbose = FALSE)
}

test_that("drive_publish() publishes Google Documents", {

  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  drive_doc <- drive_get(nm_("foo_doc"))

  ## since we haven't checked the publication status,
  ## this should be NULL
  expect_null(drive_doc[["files_resource"]][[1]][["publish"]])

  drive_doc <- drive_publish(drive_doc)

  ## the published column should be TRUE
  expect_true(drive_doc$publish$published)

  expect_message(drive_is_published(drive_doc),
                 "The latest revision of file 'foo_doc-TEST-drive-publish' is published.\n")

  ## let's unpublish it
  drive_doc <- drive_unpublish(drive_doc)

  ## now this sould be false
  expect_false(drive_doc$publish$published)
  expect_message(drive_is_published(drive_doc),
                 "The latest revision of file 'foo_doc-TEST-drive-publish' is NOT published.")
})

test_that("drive_publish() publishes Google Sheets", {

  ## we are testing this seperately because revision
  ## history is a bit different for Sheets
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  drive_sheet <- drive_get(nm_("foo_sheet"))

  ## since we haven't checked the publication status,
  ## this should be NULL
  expect_null(drive_sheet[["files_resource"]][[1]][["publish"]])

  drive_sheet <- drive_publish(drive_sheet)

  ## the published column should be TRUE
  expect_true(drive_sheet$publish$published)

  ## let's unpublish it
  drive_sheet <- drive_unpublish(drive_sheet)

  ## now this sould be false
  expect_false(drive_sheet$publish$published)
})

test_that("drive_publish() fails if the file input is not a Google Drive type", {

  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  drive_pdf <- drive_get(nm_("foo_pdf"))

  expect_error(drive_publish(drive_pdf, verbose = FALSE),
               "Only Google Drive type files can be published."
  )
})
