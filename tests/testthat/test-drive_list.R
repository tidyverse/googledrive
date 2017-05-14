internet = FALSE
test_that("drive_test when we have 2 folders of the same name & depth", {
  skip_if_not(internet)

  url <- .drive$base_url_files_v3
  ## create a folder named foo
  foo_id <- drive_mkdir("foo")$id

  ## create a folder named bar inside foo
  bar_id <- drive_mkdir("bar", path = "foo")$id

  ## let's stick a folder baz in bar, this is what we are hoping our search will find
  baz_id <- drive_mkdir("baz", path = "foo/bar")$id

  ## create a folder yo
  yo_id <- drive_mkdir("yo")$id

  ## create a folder bar in yo
  bar_2_id <- drive_mkdir("bar", path = "yo")$id

  ## now we have bar and bar_2, both folders with depth 2, but one is in foo and
  ## one is in yo. We want to peak inside the one in foo, this should have a folder
  ## baz inside it.

  expect_identical(drive_list(path = "foo/bar")$id, baz_id)

  # clean up
  ids <- list(foo_id, yo_id)
  cleanup <- purrr::map(ids, drive_file) %>%
    purrr::map(drive_delete)
})
