context("Move files")


## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-mv")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del <- drive_delete(c(nm_("foo"), nm_("bar"), nm_("baz")),
                        verbose = FALSE)
  }

  drive_mkdir(nm_("foo"))
  drive_mkdir(nm_("bar"), path = nm_("foo"))
  drive_mkdir(nm_("baz"))

}

test_that("drive_mv() can move and rename a folder", {

  skip_on_appveyor()
  skip_on_travis()
  ## currently:
  ## foo
  ## |- bar
  ## want:
  ## baz
  ## |- bar2 (where bar2 is renamed bar)
  files <- drive_search(paste(nm_("foo"), nm_("bar"), nm_("baz"), sep = "|"))
  bar_mv <- drive_mv(nm_("bar"), name = "bar2", path = nm_("baz"))

  ## the ids are identical
  expect_identical(files[grepl("bar", files$name), ]$id, bar_mv$id)

  ## bar2 is the name
  expect_identical(bar_mv$name, "bar2")

  ## baz is the parent
  parent <- unlist(promote(bar_mv, "parents")$parents)
  expect_identical(parent, files[grepl("baz", files$name), ]$id)

  ## move back
  expect_message(drive_mv("bar2", name = nm_("bar"), path = nm_("foo")),
                 "File moved")
})
