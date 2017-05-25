context("List files")

## NOTE these tests are creating & deleting the folders needed, however
## they do assume that you do NOT have a folder named "foo" or a folder
## named "yo" in your Drive root directory.

## ad hoc code for cleaning up if tests exit uncleanly
# (pesky_files <- drive_list(pattern = "foo|bar|baz|yo"))
# pesky_files$id %>% purrr::map(drive_file) %>% purrr::map(drive_delete)

nm_ <- function(x) paste0(x, "-TEST-drive-list")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del_ids <- drive_list(pattern = paste(c(nm_("foo"),
                                            nm_("foo2"),
                                            nm_("bar"),
                                            nm_("baz"),
                                            nm_("yo")),
                                          collapse = "|")
    )$id
    del_files <- purrr::map(del_ids, drive_file)
    del <- purrr::map(del_files, drive_delete, verbose = FALSE)
  }

  ## drive_list() not confused by same-named folders
  ## get_leaf() errors when two distinct folders have same path
  ## +-- foo
  ## | +-- bar
  ## | +-- bar
  ## | | +-- baz
  ## | | | +-- yo

  drive_mkdir(nm_("foo"), verbose = FALSE)
  drive_mkdir(nm_("bar"), path = nm_("foo"), verbose = FALSE)
  drive_mkdir(nm_("baz"), path = file.path(nm_("foo"), nm_("bar")), verbose = FALSE)
  drive_mkdir(nm_("yo"), path = file.path(nm_("foo"), nm_("bar"), nm_("baz")), verbose = FALSE)
  drive_mkdir(nm_("bar"), path = nm_("foo"), verbose = FALSE)

  ## get_leaf() is not confused by same-named leafs at different depths
  # +-- foo
  # | +-- bar
  # | | +-- baz
  # +-- baz
  drive_mkdir(nm_("baz"), verbose = FALSE)

  drive_mkdir(nm_("foo2"), verbose = FALSE)

  ## get_leaf() is not confused by nested same-named things

  # +-- foo (folder)
  # | +-- foo (document)

  write.table(chickwts, "chickwts.txt")
  drive_upload(input = "chickwts.txt",
               output = file.path(nm_("foo"), nm_("foo")),
               verbose = FALSE)

  ## get_leaf() is not confused by differently ordered non-leaf folders
  # +-- bar
  # | +-- foo
  #   | +-- baz (file)
  drive_mkdir(nm_("bar"), verbose = FALSE)
  drive_mkdir(nm_("foo"), nm_("bar"), verbose = FALSE)
  drive_upload(input = "chickwts.txt",
               output = file.path(nm_("bar"), nm_("foo"), nm_("baz")),
               verbose = FALSE)



  ## same-named folder and file is diagnosed, but can be disambiguated
  ## +-- foobar (folder)
  ## +-- foobar (file)
  drive_mkdir(nm_("foobar"), verbose = FALSE)
  drive_upload(input = "chickwts.txt",
               output = nm_("foobar"),
               verbose = FALSE)
  rm <- file.remove("chickwts.txt")
}


test_that("drive_list() not confused by same-named folders", {
  skip_on_appveyor()
  skip_on_travis()

  ## there should be two folders named 'bar' in 'foo'
  expect_true(all(c(nm_("bar"), nm_("bar")) %in% drive_list(path = nm_("foo"))$name))

  ## there should be no trouble telling which bar to route through
  expect_identical(nm_("yo"),
                   drive_list(path = file.path(nm_("foo"),
                                               nm_("bar"),
                                               nm_("baz"))
                   )
                   $name)

})

test_that("get_leaf() errors when two distinct folders have same path", {
  skip_on_appveyor()
  skip_on_travis()

  expect_error(
    get_leaf(file.path(nm_("foo"), nm_("bar"))),
    paste0("The path '",
           file.path(nm_("foo"), nm_("bar")),
           "' identifies more than one file:")
  )
})

test_that("get_leaf() is not confused by same-named leafs at different depths", {

  skip_on_appveyor()
  skip_on_travis()

  expect_length(get_leaf(file.path(nm_("foo"),
                                   nm_("bar"),
                                   nm_("baz"))),
                3)
})

test_that("get_leaf() is not confused by nested same-named things", {

  skip_on_appveyor()
  skip_on_travis()

  # +-- foo (folder)
  # | +-- foo (document)

  ## we've created one to be a folder and one to be a document.
  expect_true(grepl("folder", get_leaf(nm_("foo"))$mimeType))
  expect_true(grepl("text",
                    get_leaf(file.path(nm_("foo"),
                                       nm_("foo")))$mimeType))
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

  expect_true(grepl("folder",
                    get_leaf(file.path(nm_("foo"),
                                       nm_("bar"),
                                       nm_("baz"))
                    )$mimeType)
  )
  expect_true(grepl("text",
                    get_leaf(file.path(nm_("bar"),
                                       nm_("foo"),
                                       nm_("baz"))
                    )$mimeType)
  )
})

test_that("same-named folder and file is diagnosed, but can be disambiguated", {
  skip_on_appveyor()
  skip_on_travis()

  expect_error(
    drive_list(nm_("foobar")),
    paste0("The path '", nm_("foobar"), "' identifies more than one file:")
  )
  ## TO DO: change the expectation once foo/ contains a file
  expect_message(
    out <- drive_list(paste0(nm_("foobar"), "/")),
    paste0("There are no files in Google Drive path: '",paste0(nm_("foobar"), "/"),"'")
    )
  expect_is(out, "tbl_df")
  expect_identical(nrow(out), 0L)
  expect_true(all(c("name", "id") %in% names(out)))

})

## TO DO: add test for listing a single file via path, eg drive_file("foo/a_file")
