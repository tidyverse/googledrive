context("List files")

## NOTE these tests are creating & deleting the folders needed, however
## they do assume that you do NOT have a folder named "foo" or a folder
## named "yo" in your Drive root directory.

## ad hoc code for cleaning up if tests exit uncleanly
# (pesky_files <- drive_list(pattern = "foo|bar|baz|yo"))
# pesky_files$id %>% purrr::map(drive_file) %>% purrr::map(drive_delete)

test_that("drive_list when we have 2 folders of the same name & depth", {
  skip_on_appveyor()
  skip_on_travis()

  ## create a folder named foo with some suffix
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

  expect_identical(drive_list(path =  "foo/bar")$id, baz_id)

  # clean up
  ids <- c(foo_id, yo_id)
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
  yo_id <- drive_mkdir("yo", path = "foo")$id
  baz_2_id <- drive_mkdir("baz", "foo/yo")$id

  expect_identical(fum_id, drive_list("foo/bar/baz")$id)

  ## clean up
  foo_id %>%
    drive_file() %>%
    drive_delete()
})

test_that("drive_list when we have two folders of the same name in the same location, but one has unique target folder", {
  skip_on_appveyor()
  skip_on_travis()
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
    drive_file() %>%
    drive_delete()

})

test_that("drive_list errors with two folders of the same name in the same location, not unique", {
  ## Google Drive treats folders like labels, so you can have two folders with the
  ## exact same name in the same location. This is silly. At them moment, if you try
  ## to search within a folder like this, if there is nothing identifiable (as in the
  ## leafmost folder you are looking for is identical to another by name) we should give
  ## and error. For example, let's say there are 2 paths in the root with foo/bar
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
  bar_2_id <- process_request(bar_2)$id

  expect_error(
    drive_list("foo/bar"),
    "The path 'foo/bar' identifies more than one file:"
  )

  ## clean up
  clean <- c(foo_id, foo_2_id) %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)
})

test_that("drive_list errors with two folders of the same name in the root, not unique", {

  skip_on_appveyor()
  skip_on_travis()

    foo_id <- drive_mkdir("foo")$id
  foo_2_id <- drive_mkdir("foo")$id

  expect_error(
    drive_list("foo"),
    "The path 'foo' identifies more than one file:"
  )

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


## TO DO: add this as a test
## path = foo/bar/baz
## foo/bar/baz DOES exist
## but there are two folders named bar under foo, one of which hosts baz

## TO DO: add this as a test
## path = "jt01/jt02/jt03" or "jt01/jt02/jt03/"
## "jt01/jt02/jt03" exists where jt03 is a folder holding a file jt04
## "jt01/jt02/jt03" exists where jt03 is a file
## so there are two folders named jt02 inside jt01
## make sure that path = "jt01/jt02" errors because ambiguous
## make sure that path = "jt01/jt02/" errors because ambiguous
## make sure that path = "jt01/jt02/jt03" errors because ambiguous
## make sure that path = "jt01/jt02/jt03/" lists jt04
## make sure that path = "jt01/jt02/jt03/jt04" lists jt04
