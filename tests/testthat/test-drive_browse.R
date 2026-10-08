# ---- other ----
if (FALSE) {
  # how the test file was created
  # using shared-drive-capable token ...
  files <- drive_find(corpus = "allDrives", n_max = 10)
  sds <- shared_drive_find()
  x <- vec_rbind(files, sds)
  saveRDS(x, test_fixture("mix_of_files_and_teamdrives.rds"), version = 2)
}

# ---- tests ----
test_that("drive_link() extracts links for files and Team Drives, alike", {
  x <- readRDS(test_fixture("mix_of_files_and_teamdrives.rds"))
  links <- drive_link(x)
  expect_true(all(grepl("^https://.*\\.google\\.com/", links)))
  expect_identical(as_id(links), as_id(x))
})

test_that("drive_browse() passes links through", {
  skip_if(interactive())
  x <- readRDS(test_fixture("mix_of_files_and_teamdrives.rds"))
  expect_identical(drive_browse(x), drive_link(x))
})
