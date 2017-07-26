context("Download files")

# ---- nm_fun ----
nm_ <- nm_fun("-TEST-drive-download")

# ---- clean ----
if (CLEAN) {
  drive_rm(c(
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

test_that("drive_download() downloads a file", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  on.exit(unlink("description.txt"))
  expect_message(
    drive_download(file = nm_("DESC"), path = "description.txt"),
    "File downloaded"
  )
  expect_true(file.exists("description.txt"))
})

test_that("drive_download() errors if file does not exist on Drive", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  expect_error(
    drive_download(nm_("this-should-not-exist")),
    "Input does not hold exactly one Drive file"
  )
})

test_that("drive_download() converts with explicit `type`", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  nm <- paste0(nm_("DESC-doc"), ".docx")
  on.exit(unlink(nm))

  expect_message(
    drive_download(file = nm_("DESC-doc"), type = "docx"),
    "File downloaded"
  )
  expect_true(file.exists(nm))
})

test_that("drive_download() converts with type implicit in `path`", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  nm <- paste0(nm_("DESC-doc"), ".docx")
  on.exit(unlink(nm))

  expect_message(
    drive_download(file = nm_("DESC-doc"), path = nm),
    "File downloaded"
  )
  expect_true(file.exists(nm))
})

test_that("drive_download() converts using default MIME type, if necessary", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  nm <- paste0(nm_("DESC-doc"), ".docx")
  on.exit(unlink(nm))

  expect_message(
    drive_download(file = nm_("DESC-doc")),
    "File downloaded"
  )
  expect_true(file.exists(nm))
})
