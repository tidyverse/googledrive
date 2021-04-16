# this script extracts code from all individual test files to do:
#   * test setup = create the files/folders our tests expect to find on Drive
#   * test cleanup = delete the above files/folder from Drive
# execute this to get two R scripts:
#   * all-test-setup.R
#   * all-test-clean.R

library(purrr)
library(glue)
library(testthat)

## grabs code from two chunks: 'nm_fun' and chunk ('clean' or 'setup')
do_one <- function(r_file, chunk) {
  knitr::read_chunk(r_file)
  out <- c(
    knitr:::knit_code$get("nm_fun"),
    knitr:::knit_code$get(chunk)
  )
  knitr:::knit_code$restore()
  if (length(out) == 0) {
    return(NULL)
  }
  c(paste("#' ##", basename(r_file)), out)
}

test_files <- list.files(
  path = test_path(),
  pattern = "test-.+\\.R",
  full.names = TRUE
)

clean_code <- test_files %>%
  map(do_one, chunk = "clean") %>%
  compact()
setup_code <- test_files %>%
  map(do_one, chunk = "setup") %>%
  compact()

header <- "
#' ---
#' title: googledrive test {action}
#' date: '`r format(Sys.time())`'
#' output: html_document
#' ---

#' This script aggregates the test-related {action} code from all test files.

library(googledrive)
source(here::here('tests', 'testthat', 'helper.R'))
drive_user()

## change this to TRUE when you are really ready to do this!
{ACTION} <- FALSE

"

writeLines(
  c(
    glue_data(list(action = "clean", ACTION = "CLEAN"), header),
    unlist(clean_code)
  ),
  test_path("all-test-clean.R")
)
writeLines(
  c(
    glue_data(list(action = "setup", ACTION = "SETUP"), header),
    unlist(setup_code)
  ),
  test_path("all-test-setup.R")
)
