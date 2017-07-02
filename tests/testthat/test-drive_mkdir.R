context("Make folders")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-mkdir")

run <- FALSE
clean <- FALSE
if (run) {
  if (clean) {
    del <- drive_delete(c(
      nm_("OMNI-PARENT"),
      nm_("I-live-in-root")
    ))
  }
  drive_mkdir(nm_("OMNI-PARENT"))
}

test_that("drive_mkdir() errors for bad input (before hitting Drive API)", {
  expect_error(drive_mkdir(), "name must be specified")
  expect_error(drive_mkdir(letters), "length\\(path\\) == 1 is not TRUE")
  expect_error(drive_mkdir(name = letters), "length\\(name\\) == 1 is not TRUE")
})

test_that("drive_mkdir() errors if parent path does not exist", {
  skip_on_travis()
  skip_on_appveyor()
  expect_error(drive_mkdir("qweruiop", "a"))
})

test_that("drive_mkdir() errors if parent exists but is not a folder", {
  skip_on_travis()
  skip_on_appveyor()
  x <- drive_search(
    q = "mimeType != 'application/vnd.google-apps.folder'",
    n_max = 1
  )
  expect_error(
    drive_mkdir(x, "a"),
    "`path` must be a single, pre-existing folder"
  )
})

test_that("drive_mkdir() creates a folder in root folder", {
  skip_on_travis()
  skip_on_appveyor()

  on.exit(drive_delete(nm_("I-live-in-root")))
  out <- drive_mkdir(nm_("I-live-in-root"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("I-live-in-root"))
})

test_that("drive_mkdir() accepts parent folder given as dribble", {
  skip_on_travis()
  skip_on_appveyor()

  PARENT <- drive_path(nm_("OMNI-PARENT"))
  out <- drive_mkdir(PARENT, "a")
  expect_s3_class(out, "dribble")
  expect_identical(out$name, "a")
})

test_that("drive_mkdir() accepts parent folder given as file id", {
  skip_on_travis()
  skip_on_appveyor()

  PARENT <- drive_path(nm_("OMNI-PARENT"))
  out <- drive_mkdir(as_id(PARENT$id), "b")
  expect_s3_class(out, "dribble")
  expect_identical(out$name, "b")
})

test_that("drive_mkdir() accepts name as part of path", {
  skip_on_travis()
  skip_on_appveyor()

  out <- drive_mkdir(file.path(nm_("OMNI-PARENT"), "c"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, "c")
})

test_that("drive_mkdir() accepts name as part of path with trailing slash", {
  skip_on_travis()
  skip_on_appveyor()

  out <- drive_mkdir(file.path(nm_("OMNI-PARENT"), "d", ""))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, "d")
})

test_that("drive_mkdir() accepts path and name", {
  skip_on_travis()
  skip_on_appveyor()

  ## no trailing slash on path
  out <- drive_mkdir(nm_("OMNI-PARENT"), "e")
  expect_s3_class(out, "dribble")
  expect_identical(out$name, "e")

  ## yes trailing slash on path
  out <- drive_mkdir(file.path(nm_("OMNI-PARENT"), ""), "f")
  expect_s3_class(out, "dribble")
  expect_identical(out$name, "f")
})
