# ---- nm_fun ----
nm_ <- nm_fun("TEST-drive-reveal", NULL)

# ---- clean ----
if (CLEAN) {
  drive_trash(c(
    nm_("i-am-starred"),
    nm_("i-have-a-description"),
    nm_("i-am-a-google-doc")
  ))
}

# ---- setup ----
if (SETUP) {
  # some "simple" cases of digging info out of `drive_resource`
  f <- drive_example("chicken.txt")
  drive_upload(f, nm_("i-am-starred"), starred = TRUE)
  drive_upload(f, nm_("i-have-a-description"), description = "description!")
  drive_upload(f, nm_("i-am-a-google-doc"), type = "document")
}

# ---- tests ----
test_that("drive_reveal() works", {
  skip_if_no_token()
  skip_if_offline()

  dat <- drive_find(nm_(""))

  expect_snapshot(
    print(out <- drive_reveal(dat, "starred")[c("name", "starred")])
  )
  expect_true(out$starred[grepl("starred", out$name)])

  expect_snapshot(
    print(out <- drive_reveal(dat, "description")[c("name", "description")])
  )
  expect_equal(out$description[grepl("description", out$name)], "description!")

  expect_snapshot(
    print(out <- drive_reveal(dat, "mimeType")[c("name", "mime_type")])
  )
  expect_equal(
    out$mime_type[grepl("google-doc", out$name)],
    drive_mime_type("document")
  )
})

test_that("drive_reveal() can return date-times", {
  skip_if_no_token()
  skip_if_offline()

  dat <- drive_find(nm_(""))

  out <- drive_reveal(dat, "created_time")
  expect_s3_class(out$created_time, "POSIXct")
})

test_that("drive_reveal() returns list-column for non-existent `what`", {
  skip_if_no_token()
  skip_if_offline()

  dat <- drive_find(nm_(""))

  out <- drive_reveal(dat, "i_do_not_exist")
  expect_true(all(map_lgl(out$i_do_not_exist, is_null)))

  out <- drive_reveal(dat, "non_existent_time")
  expect_true(all(map_lgl(out$non_existent_time, is_null)))
})
