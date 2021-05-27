# ---- nm_fun ----
me_ <- nm_fun("TEST-drive_create")
nm_ <- nm_fun("TEST-drive_create", user_run = FALSE)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("create-in-me"),
    nm_("create-in-folder-shortcut")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("create-in-me"))
  shortcut_create(nm_("create-in-me"), name = nm_("create-in-folder-shortcut"))
}

# ---- tests ----
test_that("drive_create() errors for bad input (before hitting Drive API)", {
  expect_snapshot(drive_create(), error = TRUE)
  expect_snapshot(drive_create(letters), error = TRUE)
})

test_that("drive_create() errors if parent path does not exist", {
  skip_if_no_token()
  skip_if_offline()
  expect_snapshot(drive_create("a", path = "qweruiop"), error = TRUE)
})

test_that("drive_create() errors if parent exists but is not a folder", {
  skip_if_no_token()
  skip_if_offline()
  x <- drive_find(
    q = "mimeType != 'application/vnd.google-apps.folder'",
    # make sure we don't somehow find a folder-shortcut
    q = "mimeType != 'application/vnd.google-apps.shortcut'",
    n_max = 1
  )
  expect_snapshot(drive_create("a", path = x), error = TRUE)
})

test_that("drive_create() create specific things in root folder", {
  skip_if_no_token()
  skip_if_offline()

  defer_drive_rm(me_("docs-in-root"))
  out <- drive_create(me_("docs-in-root"), type = "document")
  expect_dribble(out)
  expect_identical(out$name, me_("docs-in-root"))
  expect_identical(out$drive_resource[[1]]$parents[[1]], root_id())
  expect_identical(
    drive_reveal(out, "mime_type")$mime_type,
    drive_mime_type("document")
  )

  defer_drive_rm(me_("sheets-in-root"))
  out <- drive_create(me_("sheets-in-root"), type = "spreadsheet")
  expect_dribble(out)
  expect_identical(out$name, me_("sheets-in-root"))
  expect_identical(out$drive_resource[[1]]$parents[[1]], root_id())
  expect_identical(
    drive_reveal(out, "mime_type")$mime_type,
    drive_mime_type("spreadsheet")
  )

  defer_drive_rm(me_("slides-in-root"))
  out <- drive_create(me_("slides-in-root"), type = "presentation")
  expect_dribble(out)
  expect_identical(out$name, me_("slides-in-root"))
  expect_identical(out$drive_resource[[1]]$parents[[1]], root_id())
  expect_identical(
    drive_reveal(out, "mime_type")$mime_type,
    drive_mime_type("presentation")
  )
})

test_that("drive_mkdir() creates a folder in root folder", {
  skip_if_no_token()
  skip_if_offline()

  defer_drive_rm(me_("folder-in-root"))
  out <- drive_mkdir(me_("folder-in-root"))
  expect_dribble(out)
  expect_identical(out$name, me_("folder-in-root"))
  expect_identical(out$drive_resource[[1]]$parents[[1]], root_id())
  expect_identical(
    drive_reveal(out, "mime_type")$mime_type,
    drive_mime_type("folder")
  )
})

test_that("drive_create() accepts parent folder given as dribble", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(me_("a"))

  PARENT <- drive_get(nm_("create-in-me"))
  out <- drive_create(me_("a"), PARENT)
  expect_dribble(out)
  expect_identical(out$name, me_("a"))
  expect_identical(
    as_id(out$drive_resource[[1]]$parents[[1]]),
    as_id(PARENT)
  )
})

test_that("drive_create() accepts parent folder given as file id", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(me_("b"))

  PARENT <- drive_get(nm_("create-in-me"))
  out <- drive_create(me_("b"), as_id(PARENT$id))
  expect_dribble(out)
  expect_identical(out$name, me_("b"))
})

test_that("drive_create() accepts name as part of path", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(me_("c"))

  out <- drive_create(file.path(nm_("create-in-me"), me_("c")))
  expect_dribble(out)
  expect_identical(out$name, me_("c"))
})

test_that("drive_create() parent separately, as a path", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(c(me_("e"), me_("f")))

  # no trailing slash on parent
  out <- drive_create(me_("e"), path = nm_("create-in-me"))
  expect_dribble(out)
  expect_identical(out$name, me_("e"))

  # yes trailing slash on parent
  out <- drive_create(me_("f"), path = append_slash(nm_("create-in-me")))
  expect_dribble(out)
  expect_identical(out$name, me_("f"))
})

test_that("drive_create() deals with folder-shortcut as path", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(c(me_("g"), me_("h")))

  target_parent_name <- nm_("create-in-me")
  shortcut_name <- nm_("create-in-folder-shortcut")
  target_parent <- drive_get(target_parent_name)

  # no trailing slash on parent
  out <- drive_create(me_("g"), path = shortcut_name)
  expect_equal(drive_reveal(out, "parent")$id_parent, target_parent$id)

  # yes trailing slash on parent
  out <- drive_create(me_("h"), path = append_slash(shortcut_name))
  expect_equal(drive_reveal(out, "parent")$id_parent, target_parent$id)
})

test_that("drive_create() catches invalid parameters", {
  skip_if_no_token()
  skip_if_offline()
  expect_snapshot(
    (expect_error(
      drive_create("hi", bunny = "foofoo"),
      class = "gargle_error_bad_params"
    ))
  )
})

test_that("drive_create() accepts metadata via ...", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(me_("create-me-in-root"))

  out <- drive_create(
    me_("create-me-in-root"),
    starred = TRUE,
    description = "files are amazing"
  )
  expect_dribble(out)
  expect_identical(nrow(out), 1L)
  expect_true(out$drive_resource[[1]]$starred)
  expect_identical(out$drive_resource[[1]]$description, "files are amazing")
})
