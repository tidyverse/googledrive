# ---- nm_fun ----
nm_ <- nm_fun("TEST-drive-download", NULL)

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
  tmpdir <-  withr::local_tempdir()
  precious_filepath <- paste0(nm_("precious"), ".txt")
  writeLines("I exist and I am special", file.path(tmpdir, precious_filepath))
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

  tmpdir <-  withr::local_tempdir()
  download_filepath <- paste0(nm_("DESC"), fileext = ".txt")

  local_drive_loud()
  expect_snapshot(
    withr::with_dir(
      tmpdir,
      out <- drive_download(nm_("DESC"), path = download_filepath)
    )
  )
  expect_true(file.exists(file.path(tmpdir, download_filepath)))
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

  tmpdir <- withr::local_tempdir(nm_("DESC-doc"))
  download_filename <- paste0(nm_("DESC-doc"), ".docx")
  local_drive_loud()

  expect_snapshot(
    withr::with_dir(
      tmpdir,
      drive_download(file = nm_("DESC-doc"), type = "docx")
    )
  )
  expect_true(file.exists(file.path(tmpdir, download_filename)))
})

test_that("drive_download() converts with type implicit in `path`", {
  skip_if_no_token()
  skip_if_offline()

  tmpdir <- withr::local_tempdir(nm_("DESC-doc"))
  download_filename <- paste0(nm_("DESC-doc"), ".docx")
  local_drive_loud()

  expect_snapshot(
    withr::with_dir(
      tmpdir,
      drive_download(file = nm_("DESC-doc"), path = download_filename)
    )
  )
  expect_true(file.exists(file.path(tmpdir, download_filename)))
})

test_that("drive_download() converts using default MIME type, if necessary", {
  skip_if_no_token()
  skip_if_offline()

  tmpdir <- withr::local_tempdir(nm_("DESC-doc"))
  download_filename <- paste0(nm_("DESC-doc"), ".docx")
  local_drive_loud()

  expect_snapshot(
    withr::with_dir(
      tmpdir,
      drive_download(file = nm_("DESC-doc"))
    )
  )
  expect_true(file.exists(file.path(tmpdir, download_filename)))
})
