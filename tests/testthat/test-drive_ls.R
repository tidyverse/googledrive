context("List files")

nm_ <- nm_fun("-TEST-drive-ls")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del <- drive_delete(c(nm_("foo"), nm_("this-should-not-exist")),
                        verbose = FALSE)
  }
  ## test that it finds at least a folder
  drive_mkdir(nm_("foo"), verbose = FALSE)
  drive_upload(
    system.file("DESCRIPTION"),
    path = file.path(nm_("foo"), nm_("a"))
  )
  drive_upload(
    system.file("DESCRIPTION"),
    path = file.path(nm_("foo"), nm_("b"))
  )
}

test_that("drive_ls() errors if file does not exist", {
  skip_on_appveyor()
  skip_on_travis()

  expect_error(
    drive_ls(nm_("this-should-not-exist")),
    "Input does not hold exactly one Drive file"
  )
})

test_that("drive_ls() outputs contents of folder", {
  skip_on_appveyor()
  skip_on_travis()

  ## path
  out <- drive_ls(nm_("foo"))
  expect_s3_class(out, "dribble")
  expect_identical(out$name, c(nm_("a"), nm_("b")))

  ## dribble
  d <- drive_path(nm_("foo"))
  out2 <- drive_ls(d)
  expect_identical(out[c("name", "id")], out2[c("name", "id")])

  ## id
  out3 <- drive_ls(as_id(d$id))
  expect_identical(out[c("name", "id")], out3[c("name", "id")])
})
