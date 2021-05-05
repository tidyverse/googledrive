# based on https://github.com/tidymodels/workflowsets/blob/main/tests/testthat/test-compat-dplyr.R

# vec_restore() ----

test_that("vec_restore() returns a dribble when it should", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_identical(vctrs::vec_restore(x, x), x)
  expect_dribble(vctrs::vec_restore(x, x))
})

test_that("vec_restore() returns dribble when row slicing", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  row1 <- x[1, ]
  row0 <- x[0, ]

  expect_dribble(vctrs::vec_restore(row1, x))
  expect_dribble(vctrs::vec_restore(row0, x))
})

test_that("vec_restore() returns bare tibble if `x` loses dribble cols", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  col <- x[1]
  expect_bare_tibble(vctrs::vec_restore(col, x))
})

# vec_ptype2() ----

test_that("vec_ptype2() is working", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  x2 <- x
  x2$y <- 1
  x3 <- x
  x3$z <- 2

  tbl <- tibble::tibble(x = 1)
  df <- data.frame(x = 1)

  # dribble-dribble
  expect_identical(vctrs::vec_ptype2(x, x), vctrs::vec_slice(x, NULL))
  expect_identical(
    vctrs::vec_ptype2(x2, x3),
    new_dribble(vctrs::df_ptype2(x2, x3))
  )

  # dribble-tbl_df
  expect_identical(
    vctrs::vec_ptype2(x, tbl),
    vctrs::vec_ptype2(new_tibble0(x), tbl)
  )
  expect_identical(
    vctrs::vec_ptype2(tbl, x),
    vctrs::vec_ptype2(tbl, new_tibble0(x))
  )

  # dribble-df
  expect_identical(
    vctrs::vec_ptype2(x, df),
    vctrs::vec_ptype2(new_tibble0(x), df)
  )
  expect_identical(
    vctrs::vec_ptype2(df, x),
    vctrs::vec_ptype2(df, new_tibble0(x))
  )
})

# vec_cast() ----

test_that("vec_cast() is working", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  x2 <- x
  x2$y <- 1
  x3 <- x
  x3$z <- 2

  tbl <- new_tibble0(x)
  df <- as.data.frame(tbl)

  # dribble-dribble
  expect_identical(vctrs::vec_cast(x, x), x)

  x2_expect <- x
  x2_expect$y <- NA_real_
  expect_identical(vctrs::vec_cast(x, x2), x2_expect)

  expect_error(
    vctrs::vec_cast(x2, x3), class = "vctrs_error_cast_lossy_dropped"
  )

  # dribble-tbl_df
  expect_identical(vctrs::vec_cast(x, tbl), tbl)
  expect_error(vctrs::vec_cast(tbl, x), class = "vctrs_error_incompatible_type")

  # dribble-df
  expect_identical(vctrs::vec_cast(x, df), df)
  expect_error(vctrs::vec_cast(df, x), class = "vctrs_error_incompatible_type")
})

# vctrs methods ----

test_that("vec_ptype() returns a dribble", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(vctrs::vec_ptype(x))
})

test_that("vec_slice() generally returns a dribble", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  expect_dribble(vctrs::vec_slice(x, 0))
  expect_dribble(vctrs::vec_slice(x, 1:2))
})

test_that("vec_c() works", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  tbl <- new_tibble0(x)

  expect_identical(vctrs::vec_c(x), x)
  expect_identical(vctrs::vec_c(x, x), new_dribble(vctrs::vec_c(tbl, tbl)))
  expect_identical(vctrs::vec_c(x[1:5, ], x[6:10, ]), x)
})

test_that("vec_rbind() works", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  tbl <- new_tibble0(x)

  expect_identical(vctrs::vec_rbind(x), x)
  expect_identical(
    vctrs::vec_rbind(x, x),
    new_dribble(vctrs::vec_rbind(tbl, tbl))
  )
  expect_identical(vctrs::vec_rbind(x[1:5, ], x[6:10, ]), x)
})

test_that("vec_cbind() returns a bare tibble", {
  x <- readRDS(test_file("just_a_dribble.rds"))

  tbl <- new_tibble0(x)

  # Unlike vec_c() and vec_rbind(), the prototype of the output comes
  # from doing `x[0]`, which will drop the dribble class
  expect_identical(vctrs::vec_cbind(x), vctrs::vec_cbind(tbl))
  expect_identical(
    vctrs::vec_cbind(x, x, .name_repair = "minimal"),
    vctrs::vec_cbind(tbl, tbl, .name_repair = "minimal")
  )
  expect_identical(
    vctrs::vec_cbind(x, tbl, .name_repair = "minimal"),
    vctrs::vec_cbind(tbl, tbl, .name_repair = "minimal")
  )
})
