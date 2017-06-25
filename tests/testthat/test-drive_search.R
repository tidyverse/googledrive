context("Search files")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-search")


run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del <- drive_delete(c(nm_("foo"), nm_("this-should-not-exist")),
                        verbose = FALSE)
  }
  ## test that it finds at least a folder
  drive_mkdir(nm_("foo"), verbose = FALSE)
}

test_that("drive_search() passes q", {
  skip_on_appveyor()
  skip_on_travis()

  ## this should find at least 1 folder (foo), and all files found should
  ## be folders
  out <- drive_search(q = "mimeType='application/vnd.google-apps.folder'")
  mtypes <- purrr::map_chr(out$files_resource, "mimeType")
  expect_true(all(mtypes == "application/vnd.google-apps.folder"))
})

test_that("drive_search() `type` filters for MIME type", {
  skip_on_appveyor()
  skip_on_travis()

  ## this should find at least 1 folder (foo), and all files found should
  ## be folders
  out <- drive_search(type = "folder")
  mtypes <- purrr::map_chr(out$files_resource, "mimeType")
  expect_true(all(mtypes == "application/vnd.google-apps.folder"))
})

test_that("drive_search() filters for the regex in `pattern`", {
  skip_on_appveyor()
  skip_on_travis()

  ## this should be able to find the folder we created, foo-TEST-drive-search
  expect_identical(drive_search(pattern = nm_("foo"))$name, nm_("foo"))

})

test_that("drive_search() errors for nonsense in `n_max`", {
  expect_error(drive_search(n_max = "a"))
  expect_error(drive_search(n_max = 1:3))
  expect_error(drive_search(n_max = -2))
})

test_that("drive_search() returns early if n_max < 1", {
  expect_identical(drive_search(n_max = 0.5), dribble())
})

test_that("drive_search() returns empty dribble if no match for `pattern`", {
  skip_on_appveyor()
  skip_on_travis()

  expect_identical(
    drive_search(pattern = nm_("this-should-not-exist")),
    dribble()
  )
})

test_that("drive_search() tolerates specification of pageSize", {
  skip_on_appveyor()
  skip_on_travis()

  expect_silent({
    default <- drive_search()
    page_size <- drive_search(pageSize = 49)
  })
  ## weird little things deep in the files resource can vary but
  ## I really don't care, e.g. thumbnailLink seems very volatile
  expect_identical(default[c("name", "id")], page_size[c("name", "id")])
})

test_that("drive_search() honors n_max", {
  skip_on_appveyor()
  skip_on_travis()

  out <- drive_search(n_max = 4)
  expect_equal(nrow(out), 4)
})
