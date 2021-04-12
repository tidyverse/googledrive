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
  on.exit(unlink("save_me.txt"))
  writeLines("I exist", "save_me.txt")
  expect_error(
    drive_download(dribble(), path = "save_me.txt"),
    "Path exists and overwrite is FALSE"
  )
})

test_that("drive_download() downloads a file and adds local_path column", {
  skip_if_no_token()
  skip_if_offline()
  local_path <- paste0(nm_("DESC"), ".txt")
  on.exit(unlink(local_path))

  # TODO: make this a snapshot test, once I have verbosity control
  out <- drive_download(nm_("DESC"), path = local_path, overwrite = TRUE)
  expect_true(file.exists(local_path))
  expect_identical(out$local_path, local_path)
})

test_that("drive_download() errors if file does not exist on Drive", {
  skip_if_no_token()
  skip_if_offline()
  expect_error(
    drive_download(nm_("this-should-not-exist")),
    "does not identify at least one"
  )
})

test_that("drive_download() converts with explicit `type`", {
  skip_if_no_token()
  skip_if_offline()

  nm <- paste0(nm_("DESC-doc"), ".docx")
  on.exit(unlink(nm))

  # TODO: make this a snapshot test, once I have verbosity control
  drive_download(file = nm_("DESC-doc"), type = "docx")
  expect_true(file.exists(nm))
})

test_that("drive_download() converts with type implicit in `path`", {
  skip_if_no_token()
  skip_if_offline()

  nm <- paste0(nm_("DESC-doc"), ".docx")
  on.exit(unlink(nm))

  # TODO: make this a snapshot test, once I have verbosity control
  drive_download(file = nm_("DESC-doc"), path = nm)
  expect_true(file.exists(nm))
})

test_that("drive_download() converts using default MIME type, if necessary", {
  skip_if_no_token()
  skip_if_offline()

  nm <- paste0(nm_("DESC-doc"), ".docx")
  on.exit(unlink(nm))

  # TODO: make this a snapshot test, once I have verbosity control
  drive_download(file = nm_("DESC-doc"))
  expect_true(file.exists(nm))
})
