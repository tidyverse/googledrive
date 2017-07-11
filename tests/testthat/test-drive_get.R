context("Get files by path or id")

nm_ <- nm_fun("-TEST-drive-get")

## clean
if (FALSE) {
  drive_rm(c(nm_("DESC-01"), nm_("DESC-02")))
}

## setup
if (FALSE) {
  drive_upload(system.file("DESCRIPTION"), name = nm_("DESC-01"))
  drive_upload(system.file("DESCRIPTION"), name = nm_("DESC-02"))
}

test_that("drive_get() 'no input' edge cases", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  expect_identical(drive_get(), dribble())
  expect_identical(drive_get(character(0)), dribble())
  expect_error(
    drive_get(id = NA_character_),
    "nzchar\\(id, keepNA = TRUE\\) is not TRUE"
  )
  expect_error(
    drive_get(id = ""),
    "nzchar\\(id, keepNA = TRUE\\) is not TRUE"
  )
})


test_that("get_path() works", {
  skip_on_appveyor()
  skip_on_travis()
  skip("not ready yet")

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
  skip("not ready yet")

  expect_identical(drive_paths("this-should-give-empty"), dribble())
  expect_identical(drive_paths(character(0)), dribble())

  two_files <- drive_paths(c(nm_("a.txt"), nm_("b.txt")))
  expect_s3_class(two_files, "dribble")
  expect_equal(nrow(two_files), 2)
  expect_identical(two_files$name, c(nm_("a.txt"), nm_("b.txt")))
})


test_that("drive_get() gives n-row output for n ids as input", {
  skip_on_appveyor()
  skip_on_travis()
  skip_if_offline()

  two_files_search <- drive_find(pattern = nm_("DESC-0[12]"))
  two_files_get <- drive_get(id = two_files_search$id)
  expect_identical(
    two_files_search[c("name", "id")],
    two_files_get[c("name", "id")]
  )
})
