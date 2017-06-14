context("Path helpers")

test_that("pth() walks the tree", {
 #   ROOT
 #  /    \
 # a      b    d
 #  \    /     |
 #    c        e    f
  df <- tibble::tribble(
    ~ id,   ~ parents,
     "c", c("a", "b"),
     "a",      "ROOT",
     "b",      "ROOT",
     "e",         "d",
     "f",        NULL
  )
  ## multiple rooted paths
  expect_identical(
    pth("c", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    list(c("c", "a", "ROOT"), c("c", "b", "ROOT"))
  )
  ## unrooted path, parent id not present in ids
  expect_identical(
    pth("e", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    list(c("e", "d", NA))
  )
  ## unrooted path, parent is NULL
  expect_identical(
    pth("f", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    list(c("f", NA))
  )
  ## id not present
  expect_identical(
    pth("g", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    list(c("g", NA))
  )
})

test_that("get_paths() correctly reports paths, no name duplication", {
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
  df$files_resource <- list(list(kind = "drive#file"))

  ## rooted path exists
  out <- get_paths(path = "a/c", .rships = df)
  expect_identical(out$id, "c")
  expect_identical(out$path, "a/c")
  out <- get_paths(path = "~/a/c", .rships = df)
  expect_identical(out$id, "c")
  expect_identical(out$path, "~/a/c")

  ## unrooted path exists
  out <- get_paths(path = "d/e", .rships = df)
  expect_identical(out$id, "e")
  expect_identical(out$path, "d/e")
  ## rooted version does not exist
  out <- get_paths(path = "~/d/e", .rships = df)
  expect_equivalent(
    out[c("name", "id", "files_resource")],
    dribble()
  )

  ## path does not exist, names do not exist
  out <- get_paths(path = "x/y/z", .rships = df)
  expect_equivalent(
    out[c("name", "id", "files_resource")],
    dribble()
  )

  ## path only partially exists, partial_ok = FALSE
  out <- get_paths(path = "a/f", .rships = df, partial_ok = FALSE)
  expect_equivalent(
    out[c("name", "id", "files_resource")],
    dribble()
  )

  ## path partially exists, non-matching name does not exist, partial_ok = TRUE
  out <- get_paths(path = "a/f", .rships = df, partial_ok = TRUE)
  expect_identical(out$id, "a")
  expect_identical(out$path, "a")

  ## path partially exists, but all names exist, partial_ok = FALSE
  out <- get_paths(path = "a/e", .rships = df, partial_ok = FALSE)
  expect_equivalent(
    out[c("name", "id", "files_resource")],
    dribble()
  )

  ## path partially exists, but all names exist, partial_ok = TRUE
  out <- get_paths(path = "a/e", .rships = df, partial_ok = TRUE)
  expect_identical(out$id, "a")
  expect_identical(out$path, "a")

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
  df$files_resource <- list(list(kind = "drive#file"))

  ## single path exists
  out <- get_paths(path = "a/b", .rships = df)
  expect_identical(out$name, "b")
  expect_identical(out$path, "a/b")

  ## multiple paths exist, depth 1
  expect_equivalent(
    get_paths(path = "a", .rships = df[df$name == "a", ]),
    tibble::tribble(
     ~ name, ~ id,          ~ files_resource, ~ path,
        "a",  "3", list(kind = "drive#file"),    "a",
        "a",  "5", list(kind = "drive#file"),    "a",
        "a",  "1", list(kind = "drive#file"),    "a",
        "a",  "4", list(kind = "drive#file"),    "a",
        "a",  "7", list(kind = "drive#file"),    "a"
    )
  )

  ## multiple paths exist, depth > 1
  expect_equivalent(
    get_paths(path = "a/a", .rships = df),
    tibble::tribble(
      ~ name, ~ id,          ~ files_resource, ~ path,
         "a",  "3", list(kind = "drive#file"),  "a/a",
         "a",  "5", list(kind = "drive#file"),  "a/a"
    )
  )

  ## multiple partial paths exist at depth > 1
  out <- get_paths(path = "a/f", .rships = df, partial_ok = FALSE)
  expect_equivalent(
    out[c("name", "id", "files_resource")],
    dribble()
  )
  expect_equivalent(
    get_paths(path = "a/f", .rships = df, partial_ok = TRUE),
    tibble::tribble(
      ~ name, ~ id,          ~ files_resource, ~ path,
         "a",  "3", list(kind = "drive#file"),    "a",
         "a",  "5", list(kind = "drive#file"),    "a",
         "a",  "1", list(kind = "drive#file"),    "a",
         "a",  "4", list(kind = "drive#file"),    "a",
         "a",  "7", list(kind = "drive#file"),    "a"
    )
  )

  ## different paths with same names in different order are resolved
  abc <- get_paths(path = "a/b/c", .rships = df, partial_ok = TRUE)
  bac <- get_paths(path = "b/a/c", .rships = df, partial_ok = TRUE)
  expect_false(identical(abc, bac))
})
