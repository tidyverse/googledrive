# ---- nm_fun ----
me_ <- nm_fun("TEST-drive-find")
nm_ <- nm_fun("TEST-drive-find", user_run = FALSE)

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
  drive_upload(
    system.file("DESCRIPTION"),
    nm_("copy-me")
  )
}

# ---- tests ----
test_that("drive_find() passes q", {
  skip_if_no_token()
  skip_if_offline()

  ## this should find at least 1 folder (find-me), and all files found should
  ## be folders
  out <- drive_find(q = "mimeType='application/vnd.google-apps.folder'")
  mtypes <- map_chr(out$drive_resource, "mimeType")
  expect_true(all(mtypes == "application/vnd.google-apps.folder"))
})

test_that("drive_find() `type` filters for MIME type", {
  skip_if_no_token()
  skip_if_offline()

  ## this should find at least 1 folder (find-me), and all files found should
  ## be folders
  out <- drive_find(type = "folder")
  mtypes <- map_chr(out$drive_resource, "mimeType")
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
  expect_snapshot(drive_find(n_max = "a"), error = TRUE)
  expect_snapshot(drive_find(n_max = 1:3), error = TRUE)
  expect_snapshot(drive_find(n_max = -2), error = TRUE)
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

  out <- drive_find(n_max = 10, pageSize = 5)
  expect_lte(nrow(out), 10)
  expect_lt(anyDuplicated(out$id), 1)
})

test_that("drive_find() honors n_max", {
  skip_if_no_token()
  skip_if_offline()

  out <- drive_find(n_max = 4)
  expect_equal(nrow(out), 4)
})

test_that("marshal_q_clauses() works in the absence of q", {
  params <- list(a = "a", b = "b")
  expect_identical(marshal_q_clauses(params), params)
})

test_that("marshal_q_clauses() handles multiple q and vector q", {
  ## non-q params present
  params <- list(a = "a", q = as.character(1:2), q = "3")
  expect_identical(
    marshal_q_clauses(params),
    list(a = "a", q = as.character(1:3))
  )

  ## non-q params absent
  params <- list(q = as.character(1:2), q = "3")
  expect_identical(
    marshal_q_clauses(params),
    list(q = as.character(1:3))
  )
})

test_that("trashed argument works", {
  skip_if_no_token()
  skip_if_offline()
  defer_drive_rm(drive_find(me_("trashed"), trashed = NA))

  trashed <- drive_cp(nm_("copy-me"), name = me_("trashed"))
  drive_trash(trashed)
  untrashed <- drive_cp(nm_("copy-me"), name = me_("untrashed"))

  out <- drive_find()
  expect_false(me_("trashed") %in% out$name)
  expect_true(me_("untrashed") %in% out$name)

  out <- drive_find(trashed = TRUE)
  expect_true(me_("trashed") %in% out$name)
  expect_false(me_("untrashed") %in% out$name)

  out <- drive_find(trashed = NA)
  expect_true(me_("trashed") %in% out$name)
  expect_true(me_("untrashed") %in% out$name)

  ## make sure that `trashed = NA` is "inert", i.e. `trashed` can still be
  ## used in user-written q clauses
  out <- drive_find(trashed = NA, q = "trashed = true")
  expect_true(me_("trashed") %in% out$name)
  expect_false(me_("untrashed") %in% out$name)
})
