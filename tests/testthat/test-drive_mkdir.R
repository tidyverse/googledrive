context("Make folders")

# ---- nm_fun ----
nm_ <- nm_fun("-TEST-drive-mkdir")

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("OMNI-PARENT"),
    nm_("I-live-in-root")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("OMNI-PARENT"))
}

# ---- tests ----
test_that("drive_mkdir() errors for bad input (before hitting Drive API)", {
  expect_error(drive_mkdir(), "name must be specified")
  expect_error(drive_mkdir(letters), "length\\(path\\) == 1 is not TRUE")
  expect_error(drive_mkdir(name = letters), "length\\(name\\) == 1 is not TRUE")
})

test_that("drive_mkdir() errors if parent path does not exist", {
  skip_on_appveyor()
  skip_if_offline()
  expect_error(drive_mkdir("qweruiop", "a"))
})

test_that("drive_mkdir() errors if parent exists but is not a folder", {
  skip_on_appveyor()
  skip_if_offline()
  x <- drive_find(
    q = "mimeType != 'application/vnd.google-apps.folder'",
    n_max = 1
  )
  expect_error(
    drive_mkdir(x, "a"),
    "`path` must be a single, pre-existing folder"
  )
})

test_that("drive_mkdir() creates a folder in root folder", {
  skip_on_appveyor()
  skip_if_offline()
  on.exit(drive_rm(nm_("I-live-in-root")))

  out <- drive_mkdir(nm_("I-live-in-root"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("I-live-in-root"))
})

test_that("drive_mkdir() accepts parent folder given as dribble", {
  skip_on_appveyor()
  skip_if_offline()
  on.exit(drive_rm(nm_("a")))

  PARENT <- drive_get(nm_("OMNI-PARENT"))
  out <- drive_mkdir(PARENT, nm_("a"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("a"))
})

test_that("drive_mkdir() accepts parent folder given as file id", {
  skip_on_appveyor()
  skip_if_offline()
  on.exit(drive_rm(nm_("b")))

  PARENT <- drive_get(nm_("OMNI-PARENT"))
  out <- drive_mkdir(as_id(PARENT$id), nm_("b"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("b"))
})

test_that("drive_mkdir() accepts name as part of path", {
  skip_on_appveyor()
  skip_if_offline()
  on.exit(drive_rm(nm_("c")))

  out <- drive_mkdir(file.path(nm_("OMNI-PARENT"), nm_("c")))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("c"))
})

test_that("drive_mkdir() accepts name as part of path with trailing slash", {
  skip_on_appveyor()
  skip_if_offline()
  on.exit(drive_rm(nm_("d")))

  out <- drive_mkdir(file.path(nm_("OMNI-PARENT"), nm_("d"), ""))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("d"))
})

test_that("drive_mkdir() accepts path and name", {
  skip_on_appveyor()
  skip_if_offline()
  on.exit(drive_rm(c(nm_("e"), nm_("f"))))

  ## no trailing slash on path
  out <- drive_mkdir(nm_("OMNI-PARENT"), nm_("e"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("e"))

  ## yes trailing slash on path
  out <- drive_mkdir(file.path(nm_("OMNI-PARENT"), ""), nm_("f"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, nm_("f"))
})
