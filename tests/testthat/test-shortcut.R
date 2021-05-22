# ---- nm_fun ----
me_ <- nm_fun("TEST-shortcut")
nm_ <- nm_fun("TEST-shortcut", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("top-level-file"),
    nm_("i-am-a-folder"),
    nm_("good-shortcut"),
    nm_("bad-shortcut")
  ))
}

# ---- setup ----
if (SETUP) {
  good_target <- drive_upload(
    system.file("DESCRIPTION"),
    nm_("top-level-file")
  )
  shortcut_create(good_target, name = nm_("good-shortcut"), overwrite = FALSE)

  drive_mkdir(nm_("i-am-a-folder"), overwrite = FALSE)

  bad_target <- drive_upload(
    system.file("DESCRIPTION"),
    nm_("target-to-delete")
  )
  shortcut_create(bad_target, name = nm_("bad-shortcut"), overwrite = FALSE)
  drive_rm(bad_target)
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

  expect_true(is_shortcut(sc))
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

test_that("shortcut_resolve() works", {
  skip_if_no_token()
  skip_if_offline()

  target_file <- drive_get(nm_("top-level-file"))
  dat <- drive_find(nm_(""), type = "shortcut")
  dat <- shortcut_resolve(dat)

  expect_true(is.na(dat$name[grep("bad", dat$name_shortcut)]))
  expect_equal(
    dat$name[grep("good", dat$name_shortcut)],
    target_file$name
  )
})
