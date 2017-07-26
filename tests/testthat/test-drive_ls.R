context("List folder contents")

# ---- nm_fun ----
nm_ <- nm_fun("-TEST-drive-ls")

# ---- clean ----
if (CLEAN) {
  drive_rm(c(
    nm_("list-me"),
    nm_("this-should-not-exist")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("list-me"))
  drive_upload(
    system.file("DESCRIPTION"),
    path = file.path(nm_("list-me"), nm_("DESCRIPTION"))
  )
  drive_upload(
    R.home('doc/html/about.html'),
    path = file.path(nm_("list-me"), nm_("about-html"))
  )
}

# ---- tests ----
test_that("drive_ls() errors if file does not exist", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  expect_error(
    drive_ls(nm_("this-should-not-exist")),
    "Input does not hold exactly one Drive file"
  )
})

test_that("drive_ls() outputs contents of folder", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  ## path
  out <- drive_ls(nm_("list-me"))
  expect_s3_class(out, "dribble")
  expect_true(setequal(out$name, c(nm_("about-html"), nm_("DESCRIPTION"))))

  ## dribble
  d <- drive_get(nm_("list-me"))
  out2 <- drive_ls(d)
  expect_identical(out[c("name", "id")], out2[c("name", "id")])

  ## id
  out3 <- drive_ls(as_id(d$id))
  expect_identical(out[c("name", "id")], out3[c("name", "id")])
})

test_that("drive_ls() passes ... through to drive_find()", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  d <- drive_get(nm_("list-me"))

  ## does user-specified q get appended to vs clobbered?
  ## if so, only about-html is listed here
  about <- drive_get(nm_("about-html"))
  out <- drive_ls(d, q = "fullText contains 'portable'")
  expect_identical(
    about[c("name", "id")],
    out[c("name", "id")]
  )

  ## does a non-q query parameter get passed through?
  ## if so, files are listed in reverse alphabetical order here
  out <- drive_ls(d, orderBy = "name desc")
  expect_identical(
    out$name,
    c(nm_("DESCRIPTION"), nm_("about-html"))
  )
})
