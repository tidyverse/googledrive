context("Make folders")

# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-mkdir")
nm_ <- nm_fun("TEST-drive-mkdir", NULL)

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
  expect_error(drive_mkdir(letters), "is_string\\(path\\) is not TRUE")
  expect_error(drive_mkdir(name = letters), "is_string\\(name\\) is not TRUE")
})

test_that("drive_mkdir() errors if parent path does not exist", {
  skip_if_no_token()
  skip_if_offline()
  expect_error(drive_mkdir("qweruiop", "a"))
})

test_that("drive_mkdir() errors if parent exists but is not a folder", {
  skip_if_no_token()
  skip_if_offline()
  x <- drive_find(
    q = "mimeType != 'application/vnd.google-apps.folder'",
    n_max = 1
  )
  expect_error(
    drive_mkdir(x, "a"),
    "Requested parent 'path' is invalid"
  )
})

test_that("drive_mkdir() creates a folder in root folder", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("I-live-in-root")))

  out <- drive_mkdir(me_("I-live-in-root"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("I-live-in-root"))
})

test_that("drive_mkdir() accepts parent folder given as dribble", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("a")))

  PARENT <- drive_get(nm_("OMNI-PARENT"))
  out <- drive_mkdir(PARENT, me_("a"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("a"))
  expect_identical(
    as_id(out$drive_resource[[1]]$parents[[1]]),
    as_id(PARENT)
  )
})

test_that("drive_mkdir() accepts parent folder given as file id", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("b")))

  PARENT <- drive_get(nm_("OMNI-PARENT"))
  out <- drive_mkdir(as_id(PARENT$id), me_("b"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("b"))
})

test_that("drive_mkdir() accepts name as part of path", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("c")))

  out <- drive_mkdir(file.path(nm_("OMNI-PARENT"), me_("c")))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("c"))
})

test_that("drive_mkdir() accepts name as part of path with trailing slash", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("d")))

  out <- drive_mkdir(file.path(nm_("OMNI-PARENT"), me_("d"), ""))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("d"))
})

test_that("drive_mkdir() accepts path and name", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(c(me_("e"), me_("f"))))

  ## no trailing slash on path
  out <- drive_mkdir(nm_("OMNI-PARENT"), me_("e"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("e"))

  ## yes trailing slash on path
  out <- drive_mkdir(file.path(nm_("OMNI-PARENT"), ""), me_("f"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("f"))
})
