context("Share files")

## NOTE this will create and delete
## files

nm_ <- nm_fun("-TEST-drive-share")

## clean
if (FALSE) {
  del <- drive_rm(nm_("chickwts"))
}
test_that("drive_share doesn't explicitly fail", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  write.table(chickwts, "chickwts.txt")
  on.exit(unlink("chickwts.txt"))

  drive_chickwts <- drive_upload(
    "chickwts.txt",
    name = nm_("chickwts"),
    verbose = FALSE
  )
  ## since we haven't updated the permissions, the permissions
  ## tibble should be just 1 row
  expect_length(drive_chickwts[["files_resource"]][[1]][["permissions"]], 1)

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
  expect_length(drive_chickwts[["files_resource"]][[1]][["permissions"]], 2)

  ## this new tibble should have type "user" and the type
  ## defined above, and the roles should be "owner" and
  ## the role defined above

  perms <- drive_chickwts[["files_resource"]][[1]][["permissions"]][[2]]
  expect_identical(perms[c("role", "type")], list(role = role, type = type))

  ## clean up
  drive_rm(drive_chickwts)
})
