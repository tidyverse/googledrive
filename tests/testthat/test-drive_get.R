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
    del <- drive_rm(c(nm_("letters-a-m.txt"), nm_("letters-n-z.txt")),
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

test_that("drive_get() 'no input' edge cases", {
  skip_on_appveyor()
  skip_on_travis()

  expect_identical(drive_get(character(0)), dribble())
  expect_error(
    drive_get(NA_character_),
    "all\\(nzchar\\(id, keepNA = TRUE\\)\\) is not TRUE"
  )
  expect_error(
    drive_get(""),
    "all\\(nzchar\\(id, keepNA = TRUE\\)\\) is not TRUE"
  )
})

test_that("drive_get() gives n-row output for n-row input", {
  skip_on_appveyor()
  skip_on_travis()

  two_files_search <- drive_find(pattern = "letters-[an]-[mz].txt")
  two_files_get <- drive_get(two_files_search$id)
  expect_identical(
    two_files_search[c("name", "id")],
    two_files_get[c("name", "id")]
  )
})
