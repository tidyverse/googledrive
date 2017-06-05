context("Get files by id")

## NOTE if you do not currently have the files needed,
## change run & clean below to TRUE to create files needed
## (CAUTION, this will delete files that will interfere)

nm_ <- nm_fun("-TEST-drive-get")

run <- FALSE
clean <- FALSE
if (run) {
  ## make sure directory is clean
  if (clean) {
    del <- drive_delete(as_dribble(c(nm_("letters-a-m.txt"),
                                     nm_("letters-n-z.txt"))),
                        verbose = FALSE)
  }
  writeLines(letters[1:13], "letters-a-m.txt")
  writeLines(letters[14:26], "letters-n-z.txt")
  drive_upload("letters-a-m.txt",
               name = nm_("letters-a-m.txt"),
               verbose = FALSE)
  drive_upload("letters-n-z.txt",
               name = nm_("letters-n-z.txt"),
               verbose = FALSE)
  rm <- unlink(c("letters-a-m.txt", "letters-n-z.txt"))
}

test_that("drive_get() give n-row output for n-row input", {
  skip_on_appveyor()
  skip_on_travis()

  nothing <- drive_get(character(0))
  expect_identical(nothing, dribble())

  two_files_search <- drive_search(pattern = "letters-[an]-[mz].txt")
  two_files_get <- drive_get(two_files_search$id)
  expect_identical(
    two_files_search[c("name", "id")],
    two_files_get[c("name", "id")]
  )
})
