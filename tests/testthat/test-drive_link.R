context("Retrieve links")

# ---- other ----
if (FALSE) {
  ## how the test file was created
  ## using Team-Drive-capable token ...
  files <- drive_find(corpora = "user,allTeamDrives")
  tds <- team_drive_find()
  x <- rbind(files, tds)
  saveRDS(x, test_file("mix_of_files_and_teamdrives.rds"))
}

# ---- tests ----
test_that("drive_link() extracts links for files and Team Drives, alike", {
  x <- readRDS(test_file("mix_of_files_and_teamdrives.rds"))
  links <- drive_link(x)
  expect_true(all(grepl("^https://.*\\.google\\.com/", links)))
  expect_identical(as_id(links), as_id(x))
})

test_that("drive_browse() passes links through", {
  if (interactive()) skip("interactive() is TRUE")
  x <- readRDS(test_file("mix_of_files_and_teamdrives.rds"))
  expect_identical(drive_browse(x), drive_link(x))
})
