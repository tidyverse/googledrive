internet <- FALSE
#internet <- TRUE

## NOTE these tests are creating & deleting the folders needed, however
## they do assume that you do NOT have a folder named "foo" or a folder
## named "yo" in your Drive root directory.

test_that("drive_list when we have 2 folders of the same name & depth", {
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

  ## test when path = foo/bar/baz when
  ## foo/yo/baz also exists, i.e. when folder will be of length >1 here.
  ## I'll put fum in "foo/bar/baz" to make sure it is finding the correct
  ## one.

  foo_id <- drive_mkdir("foo")$id
  bar_id <- drive_mkdir("bar", path = "foo")$id
  baz_id <- drive_mkdir("baz", path = "foo/bar")$id
  fum_id <- drive_mkdir("fum", path = "foo/bar/baz")$id
  yo_id <- drive_mkdir("yo", "foo")$id
  baz_2_id <- drive_mkdir("baz", "foo/yo")$id

  expect_identical(fum_id, drive_list("foo/bar/baz")$id)

  ## clean up
  foo_id %>%
    drive_file %>%
    drive_delete
})

test_that("drive_list when we have two folders of the same name in the same location (and one has the correct output)", {
  skip_if_not(internet)
  ## path = foo/bar/baz
  ## foo/bar/baz DOES exist
  ## but there are two folders named bar under foo, one of which hosts baz

  foo_id <- drive_mkdir("foo")$id
  ## bar is in foo
  bar_id <- drive_mkdir("bar", path = "foo")$id
  ## baz is in foo/bar
  baz_id <- drive_mkdir("baz", path = "foo/bar")$id
  ## let's stick something in baz to know what to look for
  yo_id <- drive_mkdir("yo", path = "foo/bar/baz")$id
  ## there is another bar in foo (without baz in it)
  bar_2_id <- drive_mkdir("bar", path = "foo")$id

  ## let's look in foo, there should be two folders named "bar"
  expect_true(all(c(bar_id, bar_2_id) %in% drive_list(path = "foo")$id))

  ## let's try to see if the function can find "baz" in the correct foo/bar
  ## (this should output yo)
  expect_identical(yo_id, drive_list(path = "foo/bar/baz")$id)

  ## clean up
  foo_id %>%
    drive_file %>%
    drive_delete

})

test_that("drive_list when we have two folders of the same name in the same location", {
  ## Google Drive treats folders like labels, so you can have two folders with the
  ## exact same name in the same location. This is silly. At them moment, if you try
  ## to search within a folder like this, if there is nothing identifiable (as in the
  ## leafmost folder you are looking for is identical to another by name) we should give
  ## and error. For example, let's say there are 2 paths in the root with foo/bar
  skip_if_not(internet)

  ## create foo/bar
  foo_id <- drive_mkdir("foo")$id
  bar_id <- drive_mkdir("bar", path = "foo")$id

  ## create another foo/bar
  foo_2_id <- drive_mkdir("foo")$id

  ## our drive_mkdir won't let you place bar in foo, since it doesn't know which foo to place
  ## it in, so we will use plain httr to make the second foo/bar
  bar_2 <- httr::POST(.drive$base_url_files_v3,
                      drive_token(),
                      body = list(
                        name = "bar",
                        parents = list(foo_2_id),
                        mimeType = "application/vnd.google-apps.folder"
                      ),
                      encode = "json"
  )
  bar_2_id <- process_request(bar_2)$id

  expect_error(drive_list("foo/bar"), "The path 'foo/bar' is not uniquely defined.")

  ## clean up
  clean <- c(foo_id, foo_2_id) %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)

  ## let's make sure it works if it is the root
  foo_id <- drive_mkdir("foo")$id
  foo_2_id <- drive_mkdir("foo")$id

  expect_error(drive_list("foo"), "The path 'foo' is not uniquely defined.")

  clean <- c(foo_id, foo_2_id) %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)

})
