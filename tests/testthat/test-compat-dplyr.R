# based on https://github.com/tidymodels/workflowsets/blob/main/tests/testthat/test-compat-dplyr.R

# ---- other ----
if (FALSE) {
  ## how the test file was created
  saveRDS(
    drive_find(n_max = 10),
    test_file("just_a_dribble.rds"),
    version = 2
  )
}

# dplyr_reconstruct() ----

test_that("dplyr_reconstruct() returns a dribble when it should", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(x)
  expect_identical(dplyr::dplyr_reconstruct(x, x), x)
})

test_that("dplyr_reconstruct() returns dribble when row slicing", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  row1 <- x[1, ]
  row0 <- x[0, ]

  expect_dribble(dplyr::dplyr_reconstruct(row1, x))
  expect_dribble(dplyr::dplyr_reconstruct(row0, x))
})

test_that("dplyr_reconstruct() returns bare tibble if dribble-ness is lost", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  col <- x[1]
  expect_bare_tibble(dplyr::dplyr_reconstruct(col, x))
})

# dplyr_col_modify() ----

test_that("can add columns and retain dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  cols <- list(x = rep(1, vec_size(x)))

  result <- dplyr::dplyr_col_modify(x, cols)

  expect_dribble(result)
  expect_identical(result$x, cols$x)
})

test_that("modifying dribble columns removes dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  cols <- list(name = rep(1L, vec_size(x)))

  result <- dplyr::dplyr_col_modify(x, cols)

  expect_bare_tibble(result)
  expect_identical(result$name, cols$name)

  cols <- list(drive_resource = rep(list(a = "a"), vec_size(x)))

  result <- dplyr::dplyr_col_modify(x, cols)

  expect_bare_tibble(result)
  expect_identical(result$drive_resource, cols$drive_resource)
})

test_that("replacing dribble col with the exact same col retains dribble-ness", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  cols <- list(id = x$id)

  result <- dplyr::dplyr_col_modify(x, cols)

  expect_dribble(result)
  expect_identical(result, x)
})

# dplyr_row_slice() ----

test_that("row slicing generally keeps the dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(dplyr::dplyr_row_slice(x, 0))
  expect_dribble(dplyr::dplyr_row_slice(x, 3))
})

test_that("dribble class is kept if row order is changed", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  loc <- rev(seq_len(nrow(x)))
  expect_dribble(dplyr::dplyr_row_slice(x, loc))
})

# bind_rows() ----

test_that("bind_rows() can keep dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(dplyr::bind_rows(x[1:2, ], x[3, ]))
})

# bind_cols() ----

test_that("bind_cols() can keep dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  y <- tibble(x = rep(1, vec_size(x)))
  expect_dribble(dplyr::bind_cols(x, y))
})

# summarise() ----

test_that("summarise() always drops the dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_bare_tibble(dplyr::summarise(x, y = 1))
  expect_bare_tibble(dplyr::summarise(
    x,
    name = name[1], id = id[1], drive_resource = drive_resource[1]
  ))
})

# group_by() ----

test_that("group_by() always returns a bare grouped-df or bare tibble", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_bare_tibble(dplyr::group_by(x))
  expect_s3_class(
    dplyr::group_by(x, id),
    c("grouped_df", "tbl_df", "tbl", "data.frame"),
    exact = TRUE
  )
})

# ungroup() ----

test_that("ungroup() returns a dribble", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(dplyr::ungroup(x))
})

# relocate() ----

test_that("relocate() keeps the dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  x <- dplyr::relocate(x, id)
  expect_dribble(x)
})

# distinct() ----

test_that("distinct() keeps the dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(dplyr::distinct(x))
})

# other dplyr verbs ----

test_that("dribble class can be retained by dplyr verbs", {
  skip_if_not_installed("dplyr")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(dplyr::arrange(x, name))
  expect_dribble(dplyr::filter(x, grepl("-TEST-", name)))
  expect_dribble(dplyr::mutate(x, a = "a"))
  expect_dribble(dplyr::slice(x, 3:4))

  x_augmented <- dplyr::mutate(x, new = name)
  expect_dribble(dplyr::rename(x_augmented, new2 = new))
  expect_dribble(dplyr::select(x_augmented, name, id, drive_resource))
})

test_that("dribble class can be dropped by dplyr verbs", {
  skip_if_not_installed("dplyr")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_false(inherits(dplyr::mutate(x, name = 1L), "dribble"))
  expect_false(inherits(dplyr::rename(x, HEY = name), "dribble"))
  expect_false(inherits(dplyr::select(x, name, id), "dribble"))
})

# joins ----

test_that("left_join() can keep dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(dplyr::left_join(x, x, by = names(x)))

  y <- tibble(id = x$id[[1]], x = 1)
  expect_dribble(dplyr::left_join(x, y, by = "id"))
})

test_that("right_join() can keep dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(dplyr::right_join(x, x, by = names(x)))

  y <- dplyr::mutate(dplyr::select(x, id), x = 1)
  expect_dribble(dplyr::right_join(x, y, by = "id"))
})

test_that("right_join() restores to the type of first input", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  y <- tibble(id = x$id[[1]], x = 1)
  # technically dribble structure is intact, but `y` is a bare tibble!
  expect_bare_tibble(dplyr::right_join(y, x, by = "id"))
})

test_that("full_join() can keep dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(dplyr::full_join(x, x, by = names(x)))
})

test_that("anti_join() can keep dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  y <- tibble(id = x$id[[1]])
  result <- dplyr::anti_join(x, y, by = "id")
  expect_equal(nrow(result), nrow(x) - 1)
  expect_dribble(result)
})

test_that("semi_join() can keep dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(dplyr::semi_join(x, x, by = names(x)))
})

test_that("nest_join() can keep dribble class", {
  skip_if_not_installed("dplyr", "1.0.0")
  x <- readRDS(test_file("just_a_dribble.rds"))

  y <- dplyr::mutate(x, foo = "bar")
  expect_dribble(dplyr::nest_join(x, y, by = names(x)))
})
