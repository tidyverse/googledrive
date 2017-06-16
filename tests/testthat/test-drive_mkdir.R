context("Make folders")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-mkdir")

clean <- FALSE
if (clean) {
  del <- drive_delete(c(nm_("foo"), nm_("bar")))
}

test_that("drive_mkdir() places folder in the correct folder", {

  skip_on_appveyor()
  skip_on_travis()

  foo <- drive_mkdir(nm_("foo"))
  ## foo
  ## |- bar
  bar <- drive_mkdir(nm_("bar"), path = nm_("foo"))
  expect_identical(bar$files_resource[[1]]$parents[[1]], foo$id)

  ## clean up
  drive_delete(nm_("foo"))
})
