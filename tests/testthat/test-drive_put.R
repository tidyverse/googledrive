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
  withr::defer({
    unlink(local_file)
    unlink(download_target)
  })
  defer_drive_rm(drive_find(me_("foo")))

  writeLines(c("beginning", "middle"), local_file)

  local_drive_loud()
  first_put <- capture.output(
    original <- drive_put(local_file),
    type = "message"
  )
  first_put[grep(basename(local_file), first_put)] <- "{RANDOM}"
  expect_snapshot(
    writeLines(first_put)
  )
  expect_s3_class(original, "dribble")

  with_drive_quiet(
    drive_download(original, path = download_target)
  )
  expect_identical(
    readLines(local_file),
    readLines(download_target)
  )

  cat("end", file = local_file, sep = "\n", append = TRUE)

  second_put <- capture.output(
    second <- drive_put(local_file),
    type = "message"
  )
  second_put[grep(basename(local_file), second_put)] <- "{RANDOM}"
  expect_snapshot(
    writeLines(second_put)
  )
  expect_identical(original$id, second$id)

  with_drive_quiet(
    drive_download(original, path = download_target, overwrite = TRUE)
  )
  expect_identical(
    readLines(local_file),
    readLines(download_target)
  )

  with_drive_quiet(
    name_collider <- drive_create(basename(local_file))
  )

  expect_error(
    drive_put(local_file),
    "Multiple items"
  )
})
