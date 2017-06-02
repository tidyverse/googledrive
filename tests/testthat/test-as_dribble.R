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

test_that("as_dribble.list() works", {

  drib_lst <- list(kind = "drive#file",
               name = "name",
               id = "id")
  drib <- as_dribble(list(drib_lst))
  expect_silent(drib <- as_dribble(list(drib_lst)))
  expect_true(all(c("name", "id", "files_resource") %in% colnames(drib)))
})
