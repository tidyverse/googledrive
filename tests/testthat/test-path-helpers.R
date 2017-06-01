context("Path helpers")

test_that("pth() walks the tree", {
 #   ROOT
 #  /    \
 # a      b    d
 #  \    /     |
 #    c        e
  df <- tibble::tribble(
    ~ id, ~ parents,
     "c", c("a", "b"),
     "a", "ROOT",
     "b", "ROOT",
     "e", "d"
  )
  ## multiple rooted paths
  expect_identical(
    pth("c", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    list(c("c", "a", "ROOT"), c("c", "b", "ROOT"))
  )
  ## unrooted path
  expect_identical(
    pth("e", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    list(c("e", "d", NA))
  )
  ## id not present
  expect_identical(
    pth("f", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    list(c("f", NA))
  )
})

test_that("get_paths() correctly reports paths, no name duplication", {
  #   ROOT
  #  /    \
  # a      b    d
  #  \    /     |
  #    c        e
  df <- tibble::tribble(
    ~ id, ~ parents,
    "c", c("a", "b"),
    "a", "ROOT",
    "b", "ROOT",
    "e", "d"
  )
  df$name <- df$id
  df$file_resource <- list(list(mimeType = ""))

  ## path exists
  out <- get_paths(path = "a/c", .rships = df)
  expect_identical(
    as.list(out),
    list(id = "c", path = "a/c", mimeType = "", parent_id = "a",
         root_path = list(c("c", "a", "ROOT")), path_orig = "a/c")
  )

  ## path does not exist, names do not exist
  expect_identical(
    get_paths(path = "x/y/z", .rships = df),
    null_path()
  )

  ## path only partially exists, partial_ok = FALSE
  expect_identical(
    get_paths(path = "a/f", .rships = df, partial_ok = FALSE),
    null_path()
  )

  ## path partially exists, non-matching name does not exist, partial_ok = TRUE
  out <- get_paths(path = "a/f", .rships = df, partial_ok = TRUE)
  expect_identical(
    as.list(out),
    list(id = "a", path = "a", mimeType = "", parent_id = "ROOT",
         root_path = list(c("a", "ROOT")), path_orig = "a/f")
  )

  ## path partially exists, but all names exist, partial_ok = FALSE
  expect_identical(
    get_paths(path = "a/e", .rships = df, partial_ok = FALSE),
    null_path()
  )

  ## path partially exists, but all names exist, partial_ok = TRUE
  out <- get_paths(path = "a/e", .rships = df, partial_ok = TRUE)
  expect_identical(
    as.list(out),
    list(id = "a", path = "a", mimeType = "", parent_id = "ROOT",
         root_path = list(c("a", "ROOT")), path_orig = "a/e")
  )

})

test_that("get_paths() works, with name duplication & multiple parents", {
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
  df$file_resource <- list(list(mimeType = ""))

  ## single path exists
  out <- get_paths(path = "a/b", .rships = df)
  expect_identical(
    as.list(out),
    list(id = "2", path = "a/b", mimeType = "", parent_id = "1",
         root_path = list(c("2", "1", "ROOT")), path_orig = "a/b")
  )

  ## multiple paths exist, depth 1
  expect_identical(
    get_paths(path = "a", .rships = df),
    tibble::tribble(
     ~ id, ~ path, ~ mimeType, ~ parent_id,    ~ root_path, ~ path_orig,
      "1",    "a",         "",      "ROOT", c("1", "ROOT"),         "a",
      "4",    "a",         "",      "ROOT", c("4", "ROOT"),         "a"
    )
  )

  ## multiple paths exist, depth > 1
  expect_identical(
    get_paths(path = "a/a", .rships = df),
    tibble::tribble(
      ~ id, ~ path, ~ mimeType, ~ parent_id,         ~ root_path, ~ path_orig,
       "3",  "a/a",         "",         "1", c("3", "1", "ROOT"),       "a/a",
       "3",  "a/a",         "",         "4", c("3", "4", "ROOT"),       "a/a",
       "5",  "a/a",         "",         "4", c("5", "4", "ROOT"),       "a/a"
    )
  )

  ## multiple partial paths exist at depth > 1
  expect_identical(
    get_paths(path = "a/f", .rships = df, partial_ok = FALSE),
    null_path()
  )
  expect_identical(
    get_paths(path = "a/f", .rships = df, partial_ok = TRUE),
    tibble::tribble(
      ~ id, ~ path, ~ mimeType, ~ parent_id,    ~ root_path, ~ path_orig,
       "1",    "a",         "",      "ROOT", c("1", "ROOT"),       "a/f",
       "4",    "a",         "",      "ROOT", c("4", "ROOT"),       "a/f"
    )
  )

  ## different paths with same names in different order are resolved
  abc <- get_paths(path = "a/b/c", .rships = df, partial_ok = TRUE)
  bac <- get_paths(path = "b/a/c", .rships = df, partial_ok = TRUE)
  expect_false(identical(abc, bac))
})

test_that("get_one_path() errors when > 1 path matches", {
  #     name(id)
  #      --(ROOT)  __
  #     /        \   \
  #  a(1)      a(4)   \ ______ b(6)
  #   |         |            /     \
  #  b(2)      b(5)        a(7)   b(10)
  #   |                    |
  #  c(3)                  c(8)
  df <- tibble::tribble(
    ~ name, ~ id, ~ parents,
       "a",  "1",    "ROOT",
       "b",  "2",       "1",
       "c",  "3",       "2",
       "a",  "4",    "ROOT",
       "b",  "5",       "4",
       "b",  "6",    "ROOT",
       "a",  "7",       "6",
       "c",  "8",       "7",
       "b", "10",       "6"
  )
  df$file_resource <- list(list(mimeType = "mimeType"))

  ## error when >1 thing
  expect_error(
    get_one_path("a/b", .rships = df),
    "Path identifies more than one file: 'a/b'"
  )

  ## error when <1 thing
  expect_error(
    get_one_path("x/y/z", .rships = df),
    "Path does not exist:"
  )
})
