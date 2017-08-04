context("Share files")

# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-share")
nm_ <- nm_fun("TEST-drive-share", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("mirrors-to-share"),
    nm_("DESC")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_upload(system.file("DESCRIPTION"), nm_("DESC"))
}

# ---- tests ----
test_that("drive_share doesn't explicitly fail", {
  skip_if_no_token()
  skip_if_offline()
  on.exit(drive_rm(me_("mirrors-to-share")))

  file <- drive_upload(
    R.home('doc/BioC_mirrors.csv'),
    name = me_("mirrors-to-share")
  )
  ## since we haven't updated the permissions, the permissions
  ## tibble should be just 1 row
  expect_length(file[["drive_resource"]][[1]][["permissions"]], 1)

  role <- "reader"
  type <- "anyone"
  ## it should tell me they've been shared
  expect_message(
    file <- drive_share(
      file,
      role = role,
      type = type
    ),
    glue::glue("\nThe permissions for file {sq(file$name)} have been updated")
  )

  ## this should now have a larger tibble
  expect_length(file[["drive_resource"]][[1]][["permissions"]], 2)

  ## this new tibble should have type "user" and the type
  ## defined above, and the roles should be "owner" and
  ## the role defined above

  perms <- file[["drive_resource"]][[1]][["permissions"]][[2]]
  expect_identical(perms[c("role", "type")], list(role = role, type = type))
})

test_that("drive_share() informatively errors if given an unknown `role` or `type`", {
  skip_if_no_token()
  skip_if_offline()

  expect_error(drive_share(nm_("DESC")), "`role` and `type` must be specified.")

  expect_error(drive_share(nm_("DESC"), role = "nonsense", type = "user"),
               "`role` must be one of the following:")

  expect_error(drive_share(nm_("DESC"), role = "writer", type = "nonsense"),
               "`type` must be one of the following:")
})
