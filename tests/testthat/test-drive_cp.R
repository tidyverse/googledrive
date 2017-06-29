context("Copy files")


## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-cp")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del <- drive_delete(c(nm_("foo"), nm_("bar"), nm_("baz")),
                        verbose = FALSE)
  }

  drive_mkdir(nm_("foo"))
  drive_upload(system.file("DESCRIPTION"), nm_("bar"), verbose = FALSE)
  drive_upload(system.file("DESCRIPTION"),
               nm_("baz"),
               type = "document",
               verbose = FALSE)

}

test_that("drive_cp() can copy a non-Google file", {
  skip_on_appveyor()
  skip_on_travis()

  bar <- drive_search(nm_("bar"))
  expect_message(bar_cp <- drive_cp(nm_("bar")), "Files copied")
  expect_identical(bar_cp$name, paste("Copy of", nm_("bar")))

  ## should have the same parent
  expect_identical(bar$files_resource[[1]]$parents,
                   bar_cp$files_resource[[1]]$parents)
})

test_that("drive_cp() can copy a Google file", {
  skip_on_appveyor()
  skip_on_travis()

  baz <- drive_search(nm_("baz"))
  expect_message(baz_cp <- drive_cp(nm_("baz")), "Files copied")
  expect_identical(baz_cp$name, paste("Copy of", nm_("baz")))

  ## should have the same parent
  expect_identical(baz$files_resource[[1]]$parents,
                   baz_cp$files_resource[[1]]$parents)
})

test_that("drive_cp() errors if given a folder", {
  skip_on_appveyor()
  skip_on_travis()

  expect_error(drive_cp(nm_("foo")), "The Drive API cannot copy folders")
})
