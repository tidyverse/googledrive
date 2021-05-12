# ---- nm_fun ----
me_ <- nm_fun("TEST-shortcut_create")
nm_ <- nm_fun("TEST-shortcut_create", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("top-level-file"),
    nm_("i-am-a-folder")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("top-level-file")
  )
  drive_mkdir(nm_("i-am-a-folder"))
}

# ---- tests ----
test_that("shortcut_create() works", {
  skip_if_no_token()
  skip_if_offline()

  target_file <- drive_get(nm_("top-level-file"))
  folder <- drive_get(nm_("i-am-a-folder"))

  # TODO: consider a snapshot test once the rlang+cli transition completes
  sc <- shortcut_create(
    target_file,
    path = folder,
    name = me_("custom-named-shortcut")
  )
  defer_drive_rm(sc)

  expect_equal(
    drive_reveal(sc, "mime_type")$mime_type,
    drive_mime_type("shortcut")
  )
  expect_equal(
    unlist(drive_reveal(sc, "parents")$parents),
    folder$id
  )
  expect_match(sc$name, "custom-named-shortcut")
})

test_that("shortcut_create() requires `name` to control `overwrite`", {
  skip_if_no_token()
  skip_if_offline()

  # TODO: consider a snapshot test once the rlang+cli transition completes
  expect_error(
    shortcut_create(nm_("top-level-file"), overwrite = FALSE)
  )
})
