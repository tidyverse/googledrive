## NOTE these tests are creating & deleting the folders needed

foo_name <- paste0("foo_", round(runif(1,0,10^12)))
yo_name <- paste0("yo_", round(runif(1,0,10^12)))

test_that("drive_list when we have 2 folders of the same name & depth", {
  skip_on_appveyor()
  skip_on_travis()

  ## create a folder named foo with some suffix
  foo_id <- drive_mkdir(foo_name)$id

  ## create a folder named bar inside foo
  bar_id <- drive_mkdir("bar", path = foo_name)$id

  ## let's stick a folder baz in bar, this is what we are hoping our search will find
  baz_id <- drive_mkdir("baz", path = paste0(foo_name,"/bar"))$id

  ## create a folder yo
  yo_id <- drive_mkdir(yo_name)$id

  ## create a folder bar in yo
  bar_2_id <- drive_mkdir("bar", path = yo_name)$id

  ## now we have bar and bar_2, both folders with depth 2, but one is in foo and
  ## one is in yo. We want to peak inside the one in foo, this should have a folder
  ## baz inside it.

  expect_identical(drive_list(path =  paste0(foo_name,"/bar"))$id, baz_id)

  # clean up
  ids <- c(foo_id, yo_id)
  cleanup <- purrr::map(ids, drive_file) %>%
    purrr::map(drive_delete)

  ## test when path = foo/bar/baz when
  ## foo/yo/baz also exists, i.e. when folder will be of length >1 here.
  ## I'll put fum in "foo/bar/baz" to make sure it is finding the correct
  ## one.

  foo_id <- drive_mkdir(foo_name)$id
  bar_id <- drive_mkdir("bar", path = foo_name)$id
  baz_id <- drive_mkdir("baz", path = paste0(foo_name, "/bar"))$id
  fum_id <- drive_mkdir("fum", path = paste0(foo_name, "/bar/baz"))$id
  yo_id <- drive_mkdir("yo", path = foo_name)$id
  baz_2_id <- drive_mkdir("baz", paste0(foo_name,"/yo"))$id

  expect_identical(fum_id, drive_list(paste0(foo_name,"/bar/baz"))$id)

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

  foo_id <- drive_mkdir(foo_name)$id
  ## bar is in foo
  bar_id <- drive_mkdir("bar", path = foo_name)$id
  ## baz is in foo/bar
  baz_id <- drive_mkdir("baz", path = paste0(foo_name,"/bar"))$id
  ## let's stick something in baz to know what to look for
  yo_id <- drive_mkdir("yo", path = paste0(foo_name,"/bar/baz"))$id
  ## there is another bar in foo (without baz in it)
  bar_2_id <- drive_mkdir("bar", path = foo_name)$id

  ## let's look in foo, there should be two folders named "bar"
  expect_true(all(c(bar_id, bar_2_id) %in% drive_list(path = foo_name)$id))

  ## let's try to see if the function can find "baz" in the correct foo/bar
  ## (this should output yo)
  expect_identical(yo_id, drive_list(path = paste0(foo_name, "/bar/baz"))$id)

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
  foo_id <- drive_mkdir(foo_name)$id
  bar_id <- drive_mkdir("bar", path = foo_name)$id

  ## create another foo/bar
  foo_2_id <- drive_mkdir(foo_name)$id

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

  expect_error(drive_list(paste0(foo_name, "/bar")),
               sprintf("The path '%s/bar' is not uniquely defined.", foo_name))

  ## clean up
  clean <- c(foo_id, foo_2_id) %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)
})
test_that("drive_list errors with two folders of the same name in the root, not unique", {

  ## let's make sure it works if it is the root
  foo_id <- drive_mkdir(foo_name)$id
  foo_2_id <- drive_mkdir(foo_name)$id

  expect_error(drive_list(foo_name),
               sprintf("The path '%s' is not uniquely defined.", foo_name))

  clean <- c(foo_id, foo_2_id) %>%
    purrr::map(drive_file) %>%
    purrr::map(drive_delete)

})
