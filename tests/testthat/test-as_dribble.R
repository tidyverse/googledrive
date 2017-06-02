context("Dribble Methods")

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
  expect_silent(empty)
  expect_equal(nrow(empty), 0)
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
