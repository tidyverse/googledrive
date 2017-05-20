context("Share files")

test_that("drive_share doesn't explicitly fail", {
  skip_on_appveyor()
  skip_on_travis()
  ## upload a file
  write.table(chickwts, "chickwts.txt")
  drive_chickwts <- drive_upload("chickwts.txt", verbose = FALSE)

  ## since we haven't updated the permissions, the permissions
  ## tibble should be just 1 row
  expect_equal(nrow(drive_chickwts$permissions), 1)

  role <- "reader"
  type <- "anyone"
  ## it should tell me they've been shared
  expect_message({
    drive_chickwts <- drive_share(
      drive_chickwts,
      role = role,
      type = type
      )
  },
  glue::glue("The permissions for file '{drive_chickwts$name}' have been updated")
  )

  ## this new drive_chickwts should have a larger tibble
  expect_equal(nrow(drive_chickwts$permissions), 2)

  ## this new tibble should have type "user" and the type
  ## defined above, and the roles should be "owner" and
  ## the role defined above

  expect_equal(drive_chickwts$permissions$type, c("user", type))
  expect_equal(drive_chickwts$permissions$role, c("owner", role))

  ## clean up
  drive_delete(drive_chickwts)
  rm <- file.remove("chickwts.txt")
})


