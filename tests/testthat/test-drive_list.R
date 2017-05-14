internet = FALSE
test_that("drive_test when we have 2 folders of the same name & depth", {
  skip_if_not(internet)

  url <- .drive$base_url_files_v3
  ## create a folder named foo
  foo <- httr::POST(url,
             drive_token(),
             body = list(name = "foo",
                         mimeType = "application/vnd.google-apps.folder"
                         ),
             encode = "json"
             )
  foo_id <- process_request(foo)$id

  ## create a folder named bar inside foo
  bar <- httr::POST(url,
                    drive_token(),
                    body = list(name = "bar",
                                mimeType = "application/vnd.google-apps.folder",
                                parents = list(foo_id)
                    ),
                    encode = "json"
  )
  bar_id <- process_request(bar)$id

  ## let's stick a folder baz in bar, this is what we are hoping our search will find

  baz <- httr::POST(url,
                    drive_token(),
                    body = list(name = "baz",
                                mimeType = "application/vnd.google-apps.folder",
                                parents = list(bar_id)
                    ),
                    encode = "json"
  )
  baz_id <- process_request(baz)$id

  ## create a folder yo
  yo <- httr::POST(url,
                  drive_token(),
                  body = list(name = "yo",
                              mimeType = "application/vnd.google-apps.folder"
                  ),
                  encode = "json"
  )
  yo_id <- process_request(yo)$id

  ## create a folder bar in yo
  bar_2 <- httr::POST(url,
                    drive_token(),
                    body = list(name = "bar",
                                mimeType = "application/vnd.google-apps.folder",
                                parents = list(yo_id)
                    ),
                    encode = "json"
  )
  bar_2_id <- process_request(bar_2)$id

  ## now we have bar and bar_2, both folders with depth 2, but one is in foo and
  ## one is in yo. We want to peak inside the one in foo, this should have a folder
  ## baz inside it.

  expect_identical(drive_list(path = "foo/bar")$id, baz_id)

  # clean up
  ids <- list(foo_id, yo_id)
  cleanup <- purrr::map(ids, drive_file) %>%
    purrr::map(drive_delete)
})
