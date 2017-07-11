context("Query paths")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-path")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del <- drive_rm(c(nm_("a.txt"), nm_("b.txt")), verbose = FALSE)
  }
  writeLines(letters[1:13], "a1.txt")
  ## TO DO: we should allow upload to same name
  ##writeLines(letters[14:26], "a2.txt")
  writeLines(letters[14:26], "b.txt")
  drive_upload("a1.txt", name = nm_("a.txt"), verbose = FALSE)
  ## drive_upload("a2.txt", name = nm_("a.txt"), verbose = FALSE)
  drive_upload("b.txt", name = nm_("b.txt"), verbose = FALSE)
  rm <- unlink(c("a1.txt", "b.txt"))
}


test_that("get_path() can return info on root folder", {
  skip_on_appveyor()
  skip_on_travis()

  out <- get_paths("~/")
  expect_length(nrow(out), 1)
  expect_identical(out$path, "~/")
})


test_that("get_path() works", {
  skip_on_appveyor()
  skip_on_travis()

  expect_identical(drive_path("this-should-give-empty"), dribble())
  expect_identical(drive_path(character(0)), dribble())

  one_file <- drive_path(nm_("a.txt"))
  expect_s3_class(one_file, "dribble")
  expect_identical(nrow(one_file), 1L)

  expect_error(drive_path(c("a", "b")), "length\\(path\\) == 1 is not TRUE")
})

test_that("get_paths() works", {
  skip_on_appveyor()
  skip_on_travis()

  expect_identical(drive_paths("this-should-give-empty"), dribble())
  expect_identical(drive_paths(character(0)), dribble())

  two_files <- drive_paths(c(nm_("a.txt"), nm_("b.txt")))
  expect_s3_class(two_files, "dribble")
  expect_equal(nrow(two_files), 2)
  expect_identical(two_files$name, c(nm_("a.txt"), nm_("b.txt")))
})
