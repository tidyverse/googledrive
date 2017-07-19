context("Update files")

nm_ <- nm_fun("-TEST-drive-update")

## clean
if (FALSE) {
  del <- drive_rm(c(
    nm_("foo"),
    nm_("not-unique"),
    nm_("does-not-exist")
  ))
}

## setup
if (FALSE) {
  drive_upload(system.file("DESCRIPTION"), nm_("foo"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
  drive_upload(system.file("DESCRIPTION"), nm_("not-unique"))
}

test_that("drive_update() updates file", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  x <- drive_find(nm_("foo"))
  y <- drive_update(system.file("DESCRIPTION"), nm_("foo"))
  expect_identical(y$id, x$id)
})

test_that("drive_update() informatively errors if the path is not unique",{
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  expect_error(drive_update(system.file("DESCRIPTION"), nm_("not-unique")),
               "Path to update is not unique")
})

test_that("drive_update() informatively errors if the path does not exist",{
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()
  expect_error(drive_update(system.file("DESCRIPTION"), nm_("does-not-exist")),
               "Input does not hold at least one Drive file")
})
