context("Share files")

## NOTE this will create and delete
## files

nm_ <- nm_fun("-TEST-drive-share")

test_that("drive_share doesn't explicitly fail", {
  skip_on_appveyor()
  skip_on_travis()

  write.table(chickwts, "chickwts.txt")
  on.exit(unlink("chickwts.txt"))

  drive_chickwts <- drive_upload(
    "chickwts.txt",
    up_name = nm_("chickwts"),
    verbose = FALSE
  )
  ## since we haven't updated the permissions, the permissions
  ## tibble should be just 1 row
  expect_length(drive_chickwts$files_resource[[1]]$permissions, 1)

  role <- "reader"
  type <- "anyone"
  ## it should tell me they've been shared
  expect_message(
    drive_chickwts <- drive_share(
      drive_chickwts,
      role = role,
      type = type
    ),
    glue::glue("The permissions for file {sq(drive_chickwts$name)} have been updated")
  )

  ## this new drive_chickwts should have a larger tibble
  expect_length(drive_chickwts$files_resource[[1]]$permissions, 2)

  ## this new tibble should have type "user" and the type
  ## defined above, and the roles should be "owner" and
  ## the role defined above

  expect_equal(drive_chickwts$files_resource[[1]]$permissions[[2]]$type, type)
  expect_equal(drive_chickwts$files_resource[[1]]$permissions[[2]]$role, role)

  ## clean up
  drive_delete(drive_chickwts)
})


