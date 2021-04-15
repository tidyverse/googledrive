# ---- tests ----
test_that("pth() walks the tree", {
 #   ROOT
 #  /    \
 # a      b    d
 #  \    /     |
 #    c        e    f
  df <- tibble::tribble(
    ~ id,   ~ parents,
     "a",      "ROOT",
     "b",      "ROOT",
     "c", c("a", "b"),
     ## d intentionlly left out
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

test_that("pth() errors for cycle", {
  #   a
  # /  \
  # \  /
  #  b
  df <- tibble::tribble(
    ~ id, ~ parents,
     "a",       "b",
     "b",       "a"
  )
  expect_snapshot(
    pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    error = TRUE
  )

  #   a
  # /  \
  # \  /
  #  -
  df <- tibble::tribble(
    ~ id, ~ parents,
     "a",       "a"
  )
  expect_snapshot(
    pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    error = TRUE
  )
})

test_that("pth() errors for duplicated kid", {
  df <- tibble::tribble(
    ~ id, ~ parents,
    "a",     "ROOT",
    "a",     "ROOT"
  )
  expect_snapshot(
    pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    error = TRUE
  )

  #   a
  # /  \
  # \  /
  #  -
  df <- tibble::tribble(
    ~ id, ~ parents,
    "a",       "a"
  )
  expect_snapshot(
    pth("a", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    error = TRUE
  )
})

test_that("pth() is correct for multiple parents, one of which is root", {
  #   ROOT
  #  /    \
  # a      \
  #  \    /
  #    b
  df <- tibble::tribble(
    ~ id,     ~ parents,
     "a",        "ROOT",
     "b", c("a", "ROOT")
  )
  expect_identical(
    pth("b", kids = df$id, elders = df$parents, stop_value = "ROOT"),
    list(c("b", "a", "ROOT"), c("b", "ROOT"))
  )
})
