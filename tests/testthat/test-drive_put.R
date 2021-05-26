# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-put")
nm_ <- nm_fun("TEST-drive-put", user_run = FALSE)

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
  put_file <- basename(local_file)
  download_target <- tempfile(me_("download"), fileext = ".txt")
  withr::defer({
    unlink(local_file)
    unlink(download_target)
  })
  defer_drive_rm(drive_find(me_("foo")))

  write_utf8(c("beginning", "middle"), local_file)

  local_drive_loud_and_wide(140)
  first_put <- capture.output(
    original <- drive_put(local_file),
    type = "message"
  )
  first_put <- first_put %>%
    scrub_filepath(local_file) %>%
    scrub_filepath(put_file) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(first_put)
  )
  expect_dribble(original)

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
  second_put <- second_put %>%
    scrub_filepath(put_file) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(second_put)
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

  # not easy to convert to snapshot, due to volatile file ids
  expect_error(
    drive_put(local_file),
    "Multiple items"
  )
})
