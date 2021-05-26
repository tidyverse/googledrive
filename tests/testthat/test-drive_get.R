# ---- nm_fun ----
nm_ <- nm_fun("TEST-drive_get", user_run = FALSE)

# ---- clean ----
if (CLEAN) {
  files <- drive_find(nm_("thing0[1234]"))
  drive_trash(files)
}

# ---- setup ----
if (SETUP) {
  file_in_root <- drive_upload(
    system.file("DESCRIPTION"),
    name = nm_("thing01")
  )
  drive_upload(system.file("DESCRIPTION"), name = nm_("thing02"))
  drive_upload(system.file("DESCRIPTION"), name = nm_("thing03"))
  folder_in_root <- drive_mkdir(nm_("thing01"))
  folder_in_folder <- drive_mkdir(nm_("thing01"), path = folder_in_root)
  file_in_folder_in_folder <- drive_cp(
    file_in_root,
    path = folder_in_folder,
    name = nm_("thing01")
  )
  drive_upload(
    system.file("DESCRIPTION"),
    path = folder_in_root,
    name = nm_("thing04")
  )
}

# ---- tests ----
test_that("drive_get() 'no input' edge cases", {
  skip_if_no_token()
  skip_if_offline()

  expect_identical(drive_get(), dribble_with_path())
  expect_identical(drive_get(""), dribble_with_path())
  expect_identical(drive_get(NULL), dribble_with_path())
  expect_identical(drive_get(character(0)), dribble_with_path())

  expect_snapshot(drive_get(id = NA_character_), error = TRUE)
  expect_snapshot(drive_get(id = ""), error = TRUE)
})

test_that("drive_get() gives n-row output for n ids as input", {
  skip_if_no_token()
  skip_if_offline()

  two_files_find <- drive_find(pattern = nm_("thing0[12]"))
  two_files_get <- drive_get(id = two_files_find$id)
  expect_identical(
    two_files_find[c("name", "id")],
    two_files_get[c("name", "id")]
  )
})

test_that("drive_get(path = ...) works", {
  skip_if_no_token()
  skip_if_offline()

  one_file <- drive_get(nm_("thing02"))
  expect_dribble(one_file)
  expect_identical(nrow(one_file), 1L)

  two_files <- drive_get(c(nm_("thing02"), nm_("thing03")))
  expect_dribble(two_files)
  expect_identical(two_files$name, c(nm_("thing02"), nm_("thing03")))
})

test_that("drive_get() for non-existent file", {
  skip_if_no_token()
  skip_if_offline()
  expect_identical(drive_get("this-should-give-empty"), dribble_with_path())
})

test_that("drive_get(path = ...) is correct wrt folder-ness, path config, rooted-ness", {
  skip_if_no_token()
  skip_if_offline()

  # files with these names exist, but not in this path configuration
  out <- drive_get(c(nm_("thing01"), nm_("thing02")))
  expect_true(all(c(nm_("thing01"), nm_("thing02")) %in% out$name))
  expect_identical(
    drive_get(file.path(nm_("thing01"), nm_("thing02"))),
    dribble_with_path()
  )

  # file exists, but we don't get if specify it must be in root
  out <- drive_get(nm_("thing04"))
  expect_identical(out$name, nm_("thing04"))
  expect_identical(
    drive_get(file.path("~", nm_("thing04"))),
    dribble_with_path()
  )

  # several files/folders exist with this name, but we only want rooted ones
  out <- drive_get(file.path("~", nm_("thing01")))
  out <- drive_reveal(out, "parent")
  ROOT_ID <- root_id()
  expect_true(all(out$id_parent == ROOT_ID))

  # several files/folders exist with this name, but we only want folders
  out <- drive_get(append_slash(nm_("thing01")))
  expect_true(all(is_folder(out)))

  # several files/folders exist with this name, but we only want rooted folders
  out <- drive_get(append_slash(file.path("~", nm_("thing01"))))
  expect_true(all(is_folder(out)))
  out <- drive_reveal(out, "parent")
  expect_true(all(out$id_parent == ROOT_ID))
})

test_that("drive_get() gets root folder", {
  skip_if_no_token()
  skip_if_offline()

  from_path <- drive_get("~/")
  from_id <- drive_get(id = "root")
  from_id2 <- drive_get(as_id("root"))
  expect_equal(from_path$name, from_id$name)
  expect_equal(from_path$id, from_id$id)
  expect_equal(from_path$name, from_id2$name)
  expect_equal(from_path$id, from_id2$id)
})

test_that("drive_get(path = ...) puts trailing slash on a folder", {
  skip_if_no_token()
  skip_if_offline()

  out <- drive_get(nm_("thing01"))
  out <- vec_slice(out, is_folder(out))
  expect_match(out$path, "/$")
})

test_that("drive_reveal_path() puts trailing slash on a folder", {
  skip_if_no_token()
  skip_if_offline()

  out <- drive_find(nm_("thing01"), type = "folder")
  out <- out %>% drive_reveal_path()
  out <- out %>% promote("mimeType")
  expect_match(out$path, "/$")
})

test_that("drive_get() + drive_reveal_path() <--> drive_get() roundtrip", {
  skip_if_no_token()
  skip_if_offline()

  file <- drive_find(nm_("thing04"))

  file_from_id <- drive_get(as_id(file$id))
  path_from_file <- drive_reveal_path(file_from_id)
  file_from_path <- drive_get(path_from_file$path)

  expect_equal(file_from_id$id, file_from_path$id)
  expect_equal(path_from_file$path, file_from_path$path)
})

test_that("drive_get() works with a URL", {
  skip_if_no_token()
  skip_if_offline()

  file <- drive_find(nm_("thing02"))

  out <- drive_get(pluck(file, "drive_resource", 1, "webViewLink"))
  expect_identical(file$id, out$id)
})
