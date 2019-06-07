context("Create files")

# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-create")
nm_ <- nm_fun("TEST-drive-create", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("create-in-me"),
    nm_("create-me-in-root")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("create-in-me"))
}

# ---- tests ----
test_that("drive_create() errors for bad input (before hitting Drive API)", {
  expect_error(drive_create(), "argument \"name\" is missing")
  expect_error(drive_create(letters), "is_string\\(name\\) is not TRUE")
})

test_that("drive_create() errors if parent path does not exist", {
  skip_if_no_token()
  skip_if_offline()
  expect_error(drive_create("a", parent = "qweruiop"))
})

test_that("drive_create() errors if parent exists but is not a folder", {
  skip_if_no_token()
  skip_if_offline()
  x <- drive_find(
    q = "mimeType != 'application/vnd.google-apps.folder'",
    n_max = 1
  )
  expect_error(
    drive_create("a", parent = x),
    "Requested parent `path` is invalid"
  )
})

test_that("drive_create() creates a document in root folder", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("create-me-in-root")))

  out <- drive_create(me_("create-me-in-root"), type = "document")
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("create-me-in-root"))
  expect_identical(out$drive_resource[[1]]$parents[[1]], root_id())
  expect_identical(
    drive_reveal_mime_type(out)$mime_type,
    drive_mime_type("document")
  )
})

test_that("drive_create() creates a spreadsheet in root folder", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("create-me-in-root")))

  out <- drive_create(me_("create-me-in-root"), type = "spreadsheet")
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("create-me-in-root"))
  expect_identical(out$drive_resource[[1]]$parents[[1]], root_id())
  expect_identical(
    drive_reveal_mime_type(out)$mime_type,
    drive_mime_type("spreadsheet")
  )
})

test_that("drive_create() creates a slides presentation in root folder", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("create-me-in-root")))

  out <- drive_create(me_("create-me-in-root"), type = "presentation")
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("create-me-in-root"))
  expect_identical(out$drive_resource[[1]]$parents[[1]], root_id())
  expect_identical(
    drive_reveal_mime_type(out)$mime_type,
    drive_mime_type("presentation")
  )
})

test_that("drive_create() accepts parent folder given as dribble", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("a")))

  PARENT <- drive_get(nm_("create-in-me"))
  out <- drive_create(me_("a"), PARENT)
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("a"))
  expect_identical(
    as_id(out$drive_resource[[1]]$parents[[1]]),
    as_id(PARENT)
  )
})

test_that("drive_create() accepts parent folder given as file id", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("b")))

  PARENT <- drive_get(nm_("create-in-me"))
  out <- drive_create(me_("b"), as_id(PARENT$id))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("b"))
})

test_that("drive_create() accepts name as part of path", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("c")))

  out <- drive_create(file.path(nm_("create-in-me"), me_("c")))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("c"))
})

test_that("drive_create() parent separately, as a path", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(c(me_("e"), me_("f"))))

  ## no trailing slash on parent
  out <- drive_create(me_("e"), parent = nm_("create-in-me"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("e"))

  ## yes trailing slash on parent
  out <- drive_create(me_("f"), file.path(nm_("create-in-me"), ""))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, me_("f"))
})

test_that("drive_create() catches invalid parameters", {
  expect_error(
    drive_create("hi", bunny = "foofoo"),
    regexp = "These parameters are unknown",
    class = "gargle_error_bad_params"
  )
})

test_that("drive_create() accepts metadata via ...", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("create-me-in-root")))

  out <- drive_create(
    me_("create-me-in-root"),
    starred = TRUE,
    description = "files are amazing"
  )
  expect_s3_class(out, "dribble")
  expect_identical(nrow(out), 1L)
  expect_true(out$drive_resource[[1]]$starred)
  expect_identical(out$drive_resource[[1]]$description, "files are amazing")
})
