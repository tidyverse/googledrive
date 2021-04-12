# ---- tests ----
test_that("pathify_*() reports correct paths, no name duplication", {
  #   ROOT
  #  /    \
  # a      b    d
  #  \    /     |
  #    c        e
  df <- tibble::tribble(
    ~ name,   ~ parents,
       "c", c("a", "b"),
       "a",      "ROOT",
       "b",      "ROOT",
       "e",         "d",
       "d",        NULL
  )
  df$id <- df$name
  df$drive_resource <- list(list(kind = "drive#file"))

  out <- pathify_prune_unnest(df, root_id = "ROOT")
  expect_identical(
    out[c("name", "path")],
    tibble::tribble(
      ~ name, ~ path,
         "c", "~/a/c",
         "c", "~/b/c",
         "a",   "~/a",
         "b",   "~/b",
         "e",   "d/e",
         "d",     "d"
    )
  )

  unrooted <- pathify_one_path("a/c", nodes = df, root_id = "ROOT")
  rooted <- pathify_one_path("~/a/c", nodes = df, root_id = "ROOT")
  expect_identical(unrooted, rooted)
  expect_identical(unrooted$path, "~/a/c")

  unrooted <- pathify_one_path("d/e", nodes = df, root_id = "ROOT")
  expect_identical(unrooted$path, "d/e")

  rooted <- pathify_one_path("~/d/e", nodes = df, root_id = "ROOT")
  expect_equal(nrow(rooted), 0)

  nope <- pathify_one_path("x/y/z", nodes = df, root_id = "ROOT")
  expect_equal(nrow(nope), 0)

  nope <- pathify_one_path("a/f", nodes = df, root_id = "ROOT")
  expect_equal(nrow(nope), 0)

  nope <- pathify_one_path("a/e", nodes = df, root_id = "ROOT")
  expect_equal(nrow(nope), 0)
})

test_that("pathify_*() reports correct paths, w/ name dup & multiple parents", {
  #     name(id)
  #      --(ROOT)  __
  #     /        \   \
  #   a(1)     a(4)   \ __ b(6)
  #   /   \    /   \        |
  # b(2)   a(3)    a(5)    a(7)
  #  |                      |
  # c(8)                   c(9)
  df <- tibble::tribble(
    ~ name, ~ id,   ~ parents,
       "a",  "3", c("1", "4"),
       "a",  "5",         "4",
       "b",  "2",         "1",
       "a",  "1",      "ROOT",
       "a",  "4",      "ROOT",
       "b",  "6",      "ROOT",
       "a",  "7",         "6",
       "c",  "8",         "2",
       "c",  "9",         "7"
  )
  df$drive_resource <- list(list(kind = "drive#file"))

  ## single path
  out <- pathify_one_path("a/b", nodes = df, root_id = "ROOT")
  expect_identical(out$name, "b")
  expect_identical(out$path, "~/a/b")
  expect_identical(out$id, "2")

  ## multiple paths exist, depth 1
  out <- pathify_one_path("a", nodes = df, root_id = "ROOT")
  expect_equal(
    out[c("name", "path", "id")],
    tibble::tribble(
      ~ name, ~ path, ~ id,
      "a",  "~/a/a", "3",
      "a",  "~/a/a", "5",
      "a",    "~/a", "1",
      "a",    "~/a", "4",
      "a",  "~/b/a", "7"
    ),
    ignore_attr = TRUE
  )

  ## multiple paths exist, depth > 1
  out <- pathify_one_path("a/a", nodes = df, root_id = "ROOT")
  expect_equal(
    out[c("name", "path", "id")],
    tibble::tribble(
      ~ name, ~ path, ~ id,
         "a",  "~/a/a", "3",
         "a",  "~/a/a", "5"
    ),
    ignore_attr = TRUE
  )

  ## different paths with same names in different order are resolved
  out <- pathify_one_path("a/b/c", nodes = df, root_id = "ROOT")
  expect_identical(out$id, "8")
  out <- pathify_one_path("b/a/c", nodes = df, root_id = "ROOT")
  expect_identical(out$id, "9")
})
