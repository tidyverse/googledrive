context("List files")

## NOTE these tests are creating & deleting the folders needed, however
## they do assume that you do NOT have a folder named "foo" or a folder
## named "yo" in your Drive root directory.

## ad hoc code for cleaning up if tests exit uncleanly
# (pesky_files <- drive_list(pattern = "foo|bar|baz|yo"))
# pesky_files$id %>% purrr::map(drive_file) %>% purrr::map(drive_delete)

test_that("drive_list() not confused by same-named folders", {
  skip_on_appveyor()
  skip_on_travis()

  foo_id <- drive_mkdir("foo")$id
  bar_id <- drive_mkdir("bar", path = "foo")$id
  baz_id <- drive_mkdir("baz", path = "foo/bar")$id
  yo_id <- drive_mkdir("yo", path = "foo/bar/baz")$id
  bar_2_id <- drive_mkdir("bar", path = "foo")$id

  ## there should be two folders named 'bar' in 'foo'
  expect_true(all(c(bar_id, bar_2_id) %in% drive_list(path = "foo")$id))

  ## there should be no trouble telling which bar to route through
  expect_identical(yo_id, drive_list(path = "foo/bar/baz")$id)

  ## clean up
  foo_id %>%
    drive_file() %>%
    drive_delete()

})

test_that("get_leaf() errors when two distinct folders have same path", {
  skip_on_appveyor()
  skip_on_travis()

  ## create foo/bar
  foo_id <- drive_mkdir("foo")$id
  bar_id <- drive_mkdir("bar", path = "foo")$id

  ## create another foo/bar
  foo_2_id <- drive_mkdir("foo")$id

  ## our drive_mkdir won't let you place bar in foo, since it doesn't know which foo to place
  ## it in, so we will use plain httr to make the second foo/bar
  bar_2 <- httr::POST("https://www.googleapis.com/drive/v3/files",
                      drive_token(),
                      body = list(
                        name = "bar",
                        parents = list(foo_2_id),
                        mimeType = "application/vnd.google-apps.folder"
                      ),
                      encode = "json"
  )
  bar_2_id <- process_response(bar_2)$id

  expect_error(
    get_leaf("foo/bar"),
    "The path 'foo/bar' identifies more than one file:"
  )

  ## clean up
  clean <- c(foo_id, foo_2_id) %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)
})

test_that("get_leaf() is not confused by same-named leafs at different depths", {

  skip_on_appveyor()
  skip_on_travis()

  # +-- foo
  # | +-- bar
  # +-- bar
  foo_id <- drive_mkdir("foo")$id
  bar_id <- drive_mkdir("bar", path = "foo/")$id
  bar_2_id <- drive_mkdir("bar")$id
  expect_identical(get_leaf("foo/bar/")$id, bar_id)

  c(foo_id, bar_2_id) %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)
})

test_that("get_leaf() is not confused by nested same-named things", {

  skip_on_appveyor()
  skip_on_travis()

  # +-- foo
  # | +-- foo
  foo_1_id <- drive_mkdir("foo")$id
  foo_2_id <- drive_mkdir("foo", path = "foo/")$id
  expect_identical(get_leaf("foo")$id, foo_1_id)
  expect_identical(get_leaf("foo/foo/")$id, foo_2_id)

  foo_1_id %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)
})

test_that("get_leaf() is not confused by differently ordered non-leaf folders", {

  skip_on_appveyor()
  skip_on_travis()

  # +-- foo
  # | +-- bar
  #   | +-- baz
  # +-- bar
  # | +-- foo
  #   | +-- baz
  foo_1_id <- drive_mkdir("foo")$id
  bar_1_id <- drive_mkdir("bar", path = "foo/")$id
  baz_1_id <- drive_mkdir("baz", path = "foo/bar/")$id
  bar_2_id <- drive_mkdir("bar")$id
  foo_2_id <- drive_mkdir("foo", path = "bar/")$id
  baz_2_id <- drive_mkdir("baz", path = "bar/foo/")$id
  expect_identical(get_leaf("foo/bar/baz")$id, baz_1_id)
  expect_identical(get_leaf("bar/foo/baz/")$id, baz_2_id)

  c(foo_1_id, bar_2_id) %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)
})

test_that("same-named folder and file is diagnosed, but can be disambiguated", {
  skip_on_appveyor()
  skip_on_travis()

  foo_dir_id <- drive_mkdir("foo")$id

  write.table(chickwts, "chickwts.txt")
  on.exit(unlink("chickwts.txt"))
  foo_file_1_id <- drive_upload("chickwts.txt", "foo")$id
  ## TO DO: when drive_upload is capable of this, uncomment it
  #foo_file_2_id <- drive_upload("chickwts.txt", "foo/foo")

  expect_error(
    drive_list("foo"),
    "The path 'foo' identifies more than one file:"
  )
  ## TO DO: change the expectation once foo/ contains a file
  expect_message(
    out <- drive_list("foo/"),
    "There are no files in Google Drive path: 'foo/'"
  )
  expect_is(out, "tbl_df")
  expect_identical(nrow(out), 0L)
  expect_true(all(c("name", "id") %in% names(out)))

  c(foo_dir_id, foo_file_1_id) %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)
})

## TO DO: add test for listing a single file via path, eg drive_file("foo/a_file")
