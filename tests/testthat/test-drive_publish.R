# ---- nm_fun ----
nm_ <- nm_fun("TEST-drive-publish", user_run = FALSE)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("foo_pdf"),
    nm_("foo_doc"),
    nm_("foo_sheet")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_upload(
    file.path(R.home("doc"), "html", "about.html"),
    name = nm_("foo_doc"),
    type = "document"
  )
  drive_upload(
    file.path(R.home("doc"), "BioC_mirrors.csv"),
    name = nm_("foo_sheet"),
    type = "spreadsheet"
  )
  drive_upload(
    file.path(R.home("doc"), "html", "RLogo.pdf"),
    name = nm_("foo_pdf")
  )
}

# ---- tests ----
test_that("drive_publish() publishes Google Documents", {
  skip_if_no_token()
  skip_if_offline()

  drive_doc <- drive_get(nm_("foo_doc"))

  ## since we haven't checked the publication status,
  ## this should be NULL
  expect_null(drive_doc[["drive_resource"]][[1]][["publish"]])

  drive_doc <- drive_publish(drive_doc)

  ## the published column should be TRUE
  expect_true(drive_doc$published)

  ## let's unpublish it
  drive_doc <- drive_unpublish(drive_doc)

  ## now this sould be false
  expect_false(drive_doc$published)
})

test_that("drive_publish() publishes Google Sheets", {
  ## we are testing this separately because revision
  ## history is a bit different for Sheets
  skip_if_no_token()
  skip_if_offline()

  drive_sheet <- drive_get(nm_("foo_sheet"))

  ## since we haven't checked the publication status,
  ## this should be NULL
  expect_null(drive_sheet[["drive_resource"]][[1]][["publish"]])

  drive_sheet <- drive_publish(drive_sheet)

  ## the published column should be TRUE
  expect_true(drive_sheet$published)

  ## let's unpublish it
  drive_sheet <- drive_unpublish(drive_sheet)

  ## now this sould be false
  expect_false(drive_sheet$published)
})

test_that("drive_publish() fails for non-native file type", {
  skip_if_no_token()
  skip_if_offline()

  drive_pdf <- drive_get(nm_("foo_pdf"))
  expect_snapshot(drive_publish(drive_pdf), error = TRUE)
})

test_that("drive_publish() is vectorized", {
  skip_if_no_token()
  skip_if_offline()

  files <- drive_get(c(nm_("foo_doc"), nm_("foo_sheet")))

  files <- drive_publish(files)
  expect_true(all(files$published))
  files <- drive_unpublish(files)
  expect_false(all(files$published))
})
