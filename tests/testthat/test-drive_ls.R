# ---- nm_fun ----
nm_ <- nm_fun("TEST-drive_ls", user_run = FALSE)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("list-me"),
    nm_("list-a-folder-shortcut"),
    nm_("this-should-not-exist"),
    nm_("topdir")
  ))
}

# ---- setup ----
if (SETUP) {
  drive_mkdir(nm_("list-me"))
  drive_upload(
    system.file("DESCRIPTION"),
    path = file.path(nm_("list-me"), nm_("DESCRIPTION"))
  )
  drive_upload(
    file.path(R.home("doc"), "html", "about.html"),
    path = file.path(nm_("list-me"), nm_("about-html"))
  )
  shortcut_create(nm_("list-me"), name = nm_("list-a-folder-shortcut"))

  ## for testing `recursive = TRUE`
  top <- drive_mkdir(nm_("topdir"))
  drive_upload(
    system.file("DESCRIPTION"),
    path = top,
    name = nm_("apple"),
    type = "document",
    starred = TRUE
  )
  folder1_level1 <- drive_mkdir(nm_("folder1-level1"), path = top)
  drive_mkdir(nm_("folder2-level1"), path = top)
  x <- drive_upload(
    system.file("DESCRIPTION"),
    path = folder1_level1,
    name = nm_("banana"),
    type = "document"
  )
  folder1_level2 <- drive_mkdir(nm_("folder1-level2"), path = folder1_level1)
  x <- drive_upload(
    system.file("DESCRIPTION"),
    path = folder1_level2,
    name = nm_("cranberry"),
    type = "document",
    starred = TRUE
  )
}

# ---- tests ----
test_that("drive_ls() errors if `path` does not exist", {
  skip_if_no_token()
  skip_if_offline()

  expect_snapshot(drive_ls(nm_("this-should-not-exist")), error = TRUE)
})

test_that("drive_ls() outputs contents of folder", {
  skip_if_no_token()
  skip_if_offline()

  ## path
  out <- drive_ls(nm_("list-me"))
  expect_dribble(out)
  expect_true(setequal(out$name, c(nm_("about-html"), nm_("DESCRIPTION"))))

  ## dribble
  d <- drive_get(nm_("list-me"))
  out2 <- drive_ls(d)
  expect_identical(out[c("name", "id")], out2[c("name", "id")])

  ## id
  out3 <- drive_ls(d$id)
  expect_identical(out[c("name", "id")], out3[c("name", "id")])
})

test_that("drive_ls() list contents of the target of a folder shortcut", {
  skip_if_no_token()
  skip_if_offline()

  target_name <- nm_("list-me")
  shortcut_name <- nm_("list-a-folder-shortcut")

  direct_ls <- drive_ls(target_name)

  local_drive_loud_and_wide()
  drive_ls_message <- capture.output(
    indirect_ls <- drive_ls(shortcut_name),
    type = "message"
  )
  drive_ls_message <- drive_ls_message |>
    scrub_filepath(target_name) |>
    scrub_filepath(shortcut_name) |>
    scrub_file_id()
  expect_snapshot(
    write_utf8(drive_ls_message)
  )

  expect_equal(direct_ls$id, indirect_ls$id)
})

test_that("drive_ls() passes ... through to drive_find()", {
  skip_if_no_token()
  skip_if_offline()

  d <- drive_get(nm_("list-me"))

  ## does user-specified q get appended to vs clobbered?
  ## if so, only about-html is listed here
  about <- drive_get(nm_("about-html"))
  out <- drive_ls(d, q = "fullText contains 'portable'", orderBy = NULL)
  expect_identical(
    about[c("name", "id")],
    out[c("name", "id")]
  )

  ## does a non-q query parameter get passed through?
  ## if so, files are listed in reverse alphabetical order here
  out <- drive_ls(d, orderBy = "name desc")
  expect_identical(
    out$name,
    c(nm_("DESCRIPTION"), nm_("about-html"))
  )
})

test_that("`recursive` does its job", {
  skip_if_no_token()
  skip_if_offline()

  out <- drive_ls(nm_("topdir"), recursive = FALSE)
  expect_true(
    all(
      c(nm_("apple"), nm_("folder1-level1"), nm_("folder2-level1")) %in%
        out$name
    )
  )

  out <- drive_ls(nm_("topdir"), recursive = TRUE)
  expect_true(
    all(
      c(
        nm_("apple"),
        nm_("folder1-level1"),
        nm_("folder2-level1"),
        nm_("banana"),
        nm_("folder1-level2"),
        nm_("cranberry")
      ) %in%
        out$name
    )
  )

  out <- drive_ls(nm_("topdir"), q = "starred = true", recursive = TRUE)
  expect_true(all(c(nm_("apple"), nm_("cranberry")) %in% out$name))
})
