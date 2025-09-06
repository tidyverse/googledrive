test_that("get_last_path_part() works", {
  expect_last_part <- function(x, tail) {
    expect_equal(get_last_path_part(x), tail)
  }
  expect_last_part("~", "~/")
  expect_last_part("~/", "~/")

  expect_last_part("abc", "abc")
  expect_last_part("abc/", "abc/")

  expect_last_part("~/abc", "abc")
  expect_last_part("~/abc/", "abc/")

  expect_last_part("~/abc/def", "def")
  expect_last_part("~/abc/def/", "def/")
  expect_last_part("abc/def", "def")
  expect_last_part("abc/def/", "def/")

  expect_last_part("~/abc/def/ghi", "ghi")
  expect_last_part("~/abc/def/ghi/", "ghi/")
  expect_last_part("abc/def/ghi", "ghi")
  expect_last_part("abc/def/ghi/", "ghi/")
})

test_that("resolve_paths() works, basic scenarios", {
  # a -- b -- c -- d
  # ??? -- e
  dr_folder <-
    list(kind = "drive#file", mimeType = "application/vnd.google-apps.folder")
  ancestors <- tibble(
    name = c("a", "b", "c"),
    id = c("1", "2", "3"),
    #    id_parent = c(NA, "1", "2"),
    drive_resource = list(
      c(dr_folder, parents = list(list())),
      c(dr_folder, parents = list(list("1"))),
      c(dr_folder, parents = list(list("2")))
    )
  )

  x <- tibble(
    name = "d",
    id = "4",
    drive_resource = list(list(kind = "drive#file", parents = list(list("3"))))
  )
  with_mock(
    root_id = function() "",
    {
      out <- resolve_paths(as_dribble(x), ancestors)
    }
  )
  expect_equal(out$path, "a/b/c/d")

  # target is a folder
  x$drive_resource <- list(c(dr_folder, parents = list(list("3"))))
  with_mock(
    root_id = function() "",
    {
      out <- resolve_paths(as_dribble(x), ancestors)
    }
  )
  expect_equal(out$path, "a/b/c/d/")

  # target's parent is not among the elders
  x <- tibble(
    name = "e",
    id = "4",
    drive_resource = list(list(kind = "drive#file", parents = list(list("9"))))
  )
  with_mock(
    root_id = function() "",
    {
      out <- resolve_paths(as_dribble(x), ancestors)
    }
  )
  expect_equal(out$path, "e")
})

test_that("resolve_paths() works, with some name duplication", {
  #     name(id)
  #      ___~(1) __
  #     /       \    \
  #   a(2)     a(3)   \ __ b(4)
  #   /         |        |
  # b(5)       b(6)    a(7)
  #  |                   |
  # c(8)                d(9)
  dr_folder <-
    list(kind = "drive#file", mimeType = "application/vnd.google-apps.folder")
  ancestors <- tibble(
    name = c("~", "a", "a", "b", "b", "b", "a"),
    id = c("1", "2", "3", "4", "5", "6", "7"),
    id_parent = c(NA, "1", "1", "1", "2", "3", "4"),
    drive_resource = list(
      c(dr_folder, parents = list(list())),
      c(dr_folder, parents = list(list("1"))),
      c(dr_folder, parents = list(list("1"))),
      c(dr_folder, parents = list(list("1"))),
      c(dr_folder, parents = list(list("2"))),
      c(dr_folder, parents = list(list("3"))),
      c(dr_folder, parents = list(list("4")))
    )
  )

  x <- tibble(
    name = c("c", "d"),
    id = c("8", "9"),
    drive_resource = list(
      list(kind = "drive#file", parents = list(list("5"))),
      list(kind = "drive#file", parents = list(list("7")))
    )
  )
  with_mock(
    root_id = function() "",
    {
      out <- resolve_paths(as_dribble(x), ancestors)
    }
  )
  expect_equal(out$path[1], "~/a/b/c")
  expect_equal(out$path[2], "~/b/a/d")
})
