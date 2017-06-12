context("Extract id from URL")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-extract-id")

clean <- FALSE
if (clean) {
  del <- drive_delete(nm_("DESCRIPTION-test"), verbose = FALSE)
}

test_that("drive_extract_id() is properly vectorized", {
  x <- c("/d/12345", "/d/12345")
  expect_equal(drive_extract_id(x), c("12345", "12345"))
  x <- c("/d/12345", "this should not work", "/d/12345")
  expect_equal(drive_extract_id(x), c("12345", NA, "12345"))
  x <- c("12345", "12345")
  expect_equal(drive_extract_id(x), c(NA, NA))
})

test_that("drive_extract_id_smarter() works with old ids", {

  skip_on_appveyor()
  skip_on_travis()

  x <- drive_upload(system.file("DESCRIPTION"),
                    name = nm_("DESCRIPTION-test"),
                    type = "spreadsheet")

  ## this old id doesn't have a /d/ in it. Our method should still
  ## be able to grab the id
  url_old <- paste0("https://docs.google.com/spreadsheet/ccc?key=", x$id,
                    "&usp=drive_web#gid=0")
  expect_equal(drive_extract_id_smarter(url_old), x$id)

  ## vectorized should still work as well
  expect_equal(drive_extract_id_smarter(c(url_old, url_old)), (c(x$id, x$id)))

  ## if the URL is not a valid URL, should return NA
  expect_equal(drive_extract_id_smarter("this shouldn't work"), NA_character_)

  ## clean up
  drive_delete(x, verbose = FALSE)
})
