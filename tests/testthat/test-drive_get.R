context("Get files by path or id")

# ---- nm_fun ----
nm_ <- nm_fun("TEST-drive-get", NULL)

# ---- clean ----
if (CLEAN) {
  files <- drive_find(nm_("thing0[1234]"))
  drive_trash(files)
  parents <- drive_find(nm_("parent0[12]"))
  drive_trash(parents)
  drive_trash(nm_("child_of_2_parents"))
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
  folder_in_folder <- drive_mkdir(nm_("thing01"), parent = folder_in_root)
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

  folder_1_of_2 <- drive_mkdir(nm_("parent01"))
  folder_2_of_2 <- drive_mkdir(nm_("parent02"))
  child_of_2_parents <- drive_upload(
    system.file("DESCRIPTION"),
    path = folder_1_of_2,
    name = nm_("child_of_2_parents")
  )
  drive_update(child_of_2_parents, addParents = as_id(folder_2_of_2))
}

# ---- tests ----
test_that("drive_get() 'no input' edge cases", {
  skip_if_no_token()
  skip_if_offline()

  expect_identical(drive_get(), dribble_with_path())
  expect_identical(drive_get(""), dribble_with_path())
  expect_identical(drive_get(NULL), dribble_with_path())
  expect_identical(drive_get(character(0)), dribble_with_path())

  expect_error(
    drive_get(id = NA_character_),
    "File ids must not be NA and cannot be the empty string"
  )
  expect_error(
    drive_get(id = ""),
    "File ids must not be NA and cannot be the empty string"
  )
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
  expect_s3_class(one_file, "dribble")
  expect_identical(nrow(one_file), 1L)

  two_files <- drive_get(c(nm_("thing02"), nm_("thing03")))
  expect_s3_class(two_files, "dribble")
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

  ## files with these names exist, but not in this path configuration
  out <- drive_get(c(nm_("thing01"), nm_("thing02")))
  expect_true(all(c(nm_("thing01"), nm_("thing02")) %in% out$name))
  expect_identical(
    drive_get(file.path(nm_("thing01"), nm_("thing02"))),
    dribble_with_path()
  )

  ## file exists, but we don't get if specify it must be in root
  out <- drive_get(nm_("thing04"))
  expect_identical(out$name, nm_("thing04"))
  expect_identical(
    drive_get(file.path("~", nm_("thing04"))),
    dribble_with_path()
  )

  ## several files/folders exist with this name, but we only want roooted ones
  out <- drive_get(file.path("~", nm_("thing01")))
  out <- promote(out, "parents")
  expect_match(unlist(out$parents), root_id())

  ## several files/folders exist with this name, but we only want folders
  out <- drive_get(append_slash(nm_("thing01")))
  out <- promote(out, "mimeType")
  expect_match(out$mimeType, "folder$")

  ## several files/folders exist with this name, but we only want rooted folders
  out <- drive_get(append_slash(file.path("~", nm_("thing01"))))
  out <- promote(out, "mimeType")
  out <- promote(out, "parents")
  expect_match(out$mimeType, "folder$")
  expect_match(unlist(out$parents), root_id())
})

test_that("drive_get() gets root folder", {
  skip_if_no_token()
  skip_if_offline()

  from_path <- drive_get("~/")
  from_path$path <- NULL
  from_id <- drive_get(id = "root")
  from_id2 <- drive_get(as_id("root"))
  expect_identical(from_path, from_id)
  expect_identical(from_path, from_id2)
})

test_that("drive_get(path = ...) puts trailing slash on a folder", {
  skip_if_no_token()
  skip_if_offline()

  out <- drive_get(nm_("thing01"))
  out <- out %>% promote("mimeType")
  out <- out[out$mimeType == "application/vnd.google-apps.folder", ]
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

  expect_identical(file_from_id$id, file_from_path$id)
  expect_identical(path_from_file$path, file_from_path$path)
})

test_that("we understand behavior with multiple parents", {
  skip_if_no_token()
  skip_if_offline()

  ## one file with two paths --> one path in, two rows out
  res <- drive_get(nm_("child_of_2_parents"))
  expect_identical(nrow(res), 2L)
  expect_identical(
    sort(res$path),
    file.path(
      "~",
      c(nm_("parent01"), nm_("parent02")),
      nm_("child_of_2_parents")
    )
  )
  expect_identical(res$id[1], res$id[2])
})

test_that("drive_get() works with a URL", {
  skip_if_no_token()
  skip_if_offline()

  file <- drive_find(nm_("thing02"))

  out <- drive_get(purrr::pluck(file, "drive_resource", 1, "webViewLink"))
  expect_identical(file$id, out$id)

})
