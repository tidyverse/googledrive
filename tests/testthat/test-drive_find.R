context("Find files")

# ---- nm_fun ----
nm_ <- nm_fun("TEST-drive-find", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("find-me"),
    nm_("this-should-not-exist")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("find-me"))
}

# ---- tests ----
test_that("drive_find() passes q", {
  skip_if_no_token()
  skip_if_offline()

  ## this should find at least 1 folder (foo), and all files found should
  ## be folders
  out <- drive_find(q = "mimeType='application/vnd.google-apps.folder'")
  mtypes <- purrr::map_chr(out$drive_resource, "mimeType")
  expect_true(all(mtypes == "application/vnd.google-apps.folder"))
})

test_that("drive_find() `type` filters for MIME type", {
  skip_if_no_token()
  skip_if_offline()

  ## this should find at least 1 folder (foo), and all files found should
  ## be folders
  out <- drive_find(type = "folder")
  mtypes <- purrr::map_chr(out$drive_resource, "mimeType")
  expect_true(all(mtypes == "application/vnd.google-apps.folder"))
})

test_that("drive_find() filters for the regex in `pattern`", {
  skip_if_no_token()
  skip_if_offline()

  expect_identical(
    drive_find(pattern = nm_("find-me"))$name,
    nm_("find-me")
  )
})

test_that("drive_find() errors for nonsense in `n_max`", {
  expect_error(drive_find(n_max = "a"))
  expect_error(drive_find(n_max = 1:3))
  expect_error(drive_find(n_max = -2))
})

test_that("drive_find() returns early if n_max < 1", {
  expect_identical(drive_find(n_max = 0.5), dribble())
})

test_that("drive_find() returns empty dribble if no match for `pattern`", {
  skip_if_no_token()
  skip_if_offline()

  expect_identical(
    drive_find(pattern = nm_("this-should-not-exist")),
    dribble()
  )
})

test_that("drive_find() tolerates specification of pageSize", {
  skip_if_no_token()
  skip_if_offline()

  expect_silent({
    default <- drive_find(verbose = FALSE)
    page_size <- drive_find(pageSize = 49, verbose = FALSE)
  })
  ## weird little things deep in the files resource can vary but
  ## I really don't care, e.g. thumbnailLink seems very volatile
  expect_identical(default[c("name", "id")], page_size[c("name", "id")])
})

test_that("drive_find() honors n_max", {
  skip_if_no_token()
  skip_if_offline()

  out <- drive_find(n_max = 4)
  expect_equal(nrow(out), 4)
})

test_that("marshal_q_clauses() works in the absence of q", {
  ## works = adds 'q = "trashed = false"'
  expect_identical(marshal_q_clauses(list()), list(q = "trashed = false"))

  params <- list(a = "a", b = "b")
  expect_identical(
    marshal_q_clauses(params),
    c(params, q = "trashed = false")
  )
})

test_that("marshal_q_clauses() handles multiple q and vector q", {
  ## non-q params present
  params <- list(a = "a", q = as.character(1:2), q = "3")
  expect_identical(
    marshal_q_clauses(params),
    list(a = "a", q = c(as.character(1:3), "trashed = false"))
  )

  ## non-q params absent
  params <- list(q = as.character(1:2), q = "3")
  expect_identical(
    marshal_q_clauses(params),
    list(q = c(as.character(1:3), "trashed = false"))
  )
})

test_that("marshal_q_clauses() doesn't clobber user's trash wishes", {
  params <- list(q = "trashed = true")
  expect_identical(marshal_q_clauses(params), params)

  params <- list(q = c("trashed = true", "trashed = false"))
  expect_identical(marshal_q_clauses(params), params)

  ## funky whitespace
  params <- list(q = "  trashed= true")
  expect_identical(marshal_q_clauses(params), params)

  ## funky whitespace + not equal
  params <- list(q = "trashed !=false ")
  expect_identical(marshal_q_clauses(params), params)
})
