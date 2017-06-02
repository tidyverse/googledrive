context("Dribble methods")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-as-dribble")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del_ids <- drive_search(pattern = nm_("letters.txt"))$id
    if (!is.null(del_ids)) {
      del_files <- purrr::map(drive_id(del_ids), drive_get)
      del <- purrr::map(del_files, drive_delete)
    }
  }
  writeLines(letters, "letters.txt")
  drive_upload("letters.txt",
               up_name = nm_("letters.txt"),
               verbose = FALSE)
  rm <- unlink("letters.txt")
}

test_that("as_dribble.data.frame() checks properly", {
  d <- tibble::tibble(
    name = character(),
    id = character(),
    files_resource = list()
  )
  expect_silent(as_dribble(d))

  d <- tibble::tibble(
    name = character(),
    id = numeric(),
    files_resource = list()
  )
  expect_error(as_dribble(d), "Invalid dribble.")
})

test_that("as_dribble.character() works", {
  skip_on_appveyor()
  skip_on_travis()

  empty <- as_dribble("this-should-give-empty")
  expect_is(empty, "dribble")
  expect_identical(nrow(empty), 0L)

  one_file <- as_dribble(nm_("letters.txt"))
  expect_is(one_file, "dribble")
  expect_identical(nrow(one_file), 1L)
})

test_that("as_dribble.list() works for good input", {

  drib_lst <- list(
    name = "name",
    id = "id",
    kind = "drive#file"
  )
  expect_silent(drib <- as_dribble(list(drib_lst)))
  expect_is(drib, "dribble")
})

test_that("as_dribble.list() catches bad input", {
  ## not testing error messages, as_dribble.list() intended for internal use
  drib_lst <- list(
    name = "name"
  )
  expect_error(drib <- as_dribble(list(drib_lst)))

  drib_lst <- list(
    name = "name",
    id = "id",
    kind = "whatever"
  )
  expect_error(drib <- as_dribble(list(drib_lst)))
})

test_that("promote() works when pull present, absent, and input is trivial", {
  x <- tibble::tibble(
    name = c("a", "b"),
    id = c("1", "2"),
    files_resource = list(list(foo = "a1"), list(foo = "b2"))
  )

  ## foo is present
  out <- promote(x, "foo")
  expect_identical(out, tibble::add_column(x, foo = c("a1", "b2")))

  ## bar is not present
  out <- promote(x, "bar")
  expect_identical(
    out,
    tibble::add_column(x, bar = list(NULL, NULL))
  )

  ## input dribble has zero rows
  x <- dribble()
  out <- promote(x, "bar")
  expect_identical(out, tibble::add_column(x, bar = list()))
})
