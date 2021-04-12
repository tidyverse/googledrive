# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-put")
nm_ <- nm_fun("TEST-drive-put", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    # no current need
  ))
}

# ---- setup ----
if (SETUP) {
  # no current need
}

# ---- tests ----

test_that("drive_put() works", {
  skip_if_no_token()
  skip_if_offline()

  local_file <- tempfile(me_("foo"), fileext = ".txt")
  download_target <- tempfile(me_("download"), fileext = ".txt")
  on.exit({
    unlink(local_file)
    unlink(download_target)
    drive_rm(drive_find(me_("foo")))
  })

  writeLines(c("beginning", "middle"), local_file)

  # TODO: make this a snapshot test, once I have verbosity control
  original <- drive_put(local_file)
  expect_s3_class(original, "dribble")

  drive_download(original, path = download_target)
  expect_identical(
    readLines(local_file),
    readLines(download_target)
  )

  cat("end", file = local_file, sep = "\n", append = TRUE)

  # TODO: make this a snapshot test, once I have verbosity control
  second <- drive_put(local_file)
  expect_identical(original$id, second$id)

  drive_download(original, path = download_target, overwrite = TRUE)
  expect_identical(
    readLines(local_file),
    readLines(download_target)
  )

  name_collider <- drive_create(basename(local_file))

  expect_error(
    drive_put(local_file),
    "Multiple items"
  )
})
