# ---- nm_fun ----
nm_ <- nm_fun("TEST-drive_download", user_run = FALSE)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("DESC"),
    nm_("DESC-doc")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_upload(system.file("DESCRIPTION"), nm_("DESC"))
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("DESC-doc"),
    type = "document"
  )
}

# ---- tests ----
test_that("drive_download() won't overwrite existing file", {
  tmpdir <- withr::local_tempdir()
  precious_filepath <- paste0(nm_("precious"), ".txt")
  write_utf8("I exist and I am special", file.path(tmpdir, precious_filepath))
  expect_snapshot(
    withr::with_dir(
      tmpdir,
      drive_download(dribble(), path = precious_filepath)
    ),
    error = TRUE
  )
})

test_that("drive_download() downloads a file and adds local_path column", {
  skip_if_no_token()
  skip_if_offline()

  file_to_download <- nm_("DESC")
  download_filepath <- withr::local_file(
    tempfile(file_to_download, fileext = ".txt")
  )

  local_drive_loud_and_wide()
  drive_download_message <- capture.output(
    out <- drive_download(file_to_download, path = download_filepath),
    type = "message"
  )
  # the order of scrubbing matters here
  drive_download_message <- drive_download_message %>%
    scrub_filepath(download_filepath) %>%
    scrub_filepath(file_to_download) %>%
    scrub_file_id()

  expect_snapshot(
    write_utf8(drive_download_message)
  )

  expect_true(file.exists(download_filepath))
  expect_identical(out$local_path, download_filepath)
})

test_that("drive_download() errors if file does not exist on Drive", {
  skip_if_no_token()
  skip_if_offline()
  expect_snapshot(drive_download(nm_("this-should-not-exist")), error = TRUE)
})

test_that("drive_download() converts with explicit `type`", {
  skip_if_no_token()
  skip_if_offline()

  file_to_download <- nm_("DESC-doc")
  tmpdir <- withr::local_tempdir(file_to_download)
  download_filename <- paste0(file_to_download, ".docx")
  local_drive_loud_and_wide()

  drive_download_message <- capture.output(
    withr::with_dir(
      tmpdir,
      drive_download(file = file_to_download, type = "docx")
    ),
    type = "message"
  )
  drive_download_message <- drive_download_message %>%
    scrub_filepath(download_filename) %>%
    scrub_filepath(file_to_download) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_download_message)
  )

  expect_true(file.exists(file.path(tmpdir, download_filename)))
})

test_that("drive_download() converts with type implicit in `path`", {
  skip_if_no_token()
  skip_if_offline()

  file_to_download <- nm_("DESC-doc")
  tmpdir <- withr::local_tempdir(file_to_download)
  download_filename <- paste0(file_to_download, ".docx")
  local_drive_loud_and_wide()

  drive_download_message <- capture.output(
    withr::with_dir(
      tmpdir,
      drive_download(file = file_to_download, path = download_filename)
    ),
    type = "message"
  )
  drive_download_message <- drive_download_message %>%
    scrub_filepath(download_filename) %>%
    scrub_filepath(file_to_download) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_download_message)
  )

  expect_true(file.exists(file.path(tmpdir, download_filename)))
})

test_that("drive_download() converts using default MIME type, if necessary", {
  skip_if_no_token()
  skip_if_offline()

  file_to_download <- nm_("DESC-doc")
  tmpdir <- withr::local_tempdir(file_to_download)
  download_filename <- paste0(file_to_download, ".docx")
  local_drive_loud_and_wide()

  drive_download_message <- capture.output(
    withr::with_dir(
      tmpdir,
      drive_download(file = file_to_download)
    ),
    type = "message"
  )
  drive_download_message <- drive_download_message %>%
    scrub_filepath(download_filename) %>%
    scrub_filepath(file_to_download) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_download_message)
  )

  expect_true(file.exists(file.path(tmpdir, download_filename)))
})

test_that("drive_download() respects given extension when `type` specified", {
  skip_if_no_token()
  skip_if_offline()

  file_to_download <- nm_("DESC-doc")
  tmpdir <- withr::local_tempdir(file_to_download)
  download_filename <- paste0(file_to_download, ".md")
  local_drive_loud_and_wide()

  drive_download_message <- capture.output(
    withr::with_dir(
      tmpdir,
      drive_download(
        file = file_to_download,
        type = "text/x-markdown",
        path = download_filename
      )
    ),
    type = "message"
  )
  drive_download_message <- drive_download_message %>%
    scrub_filepath(download_filename) %>%
    scrub_filepath(file_to_download) %>%
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_download_message)
  )

  expect_true(file.exists(file.path(tmpdir, download_filename)))
})
