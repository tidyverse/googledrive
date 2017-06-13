## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
## use a token from our development account
## special care with path because wd is docs/ during pkgdown::build_site()
token_path <- rprojroot::find_package_root_file("tidyverse-noncaching-token.rds")
googledrive::drive_auth(token_path)

## ------------------------------------------------------------------------
library(googledrive)

## ------------------------------------------------------------------------
(x <- drive_search())

## ------------------------------------------------------------------------
## just folders
drive_search(q = "mimeType = 'application/vnd.google-apps.folder'") %>% head(3)

## just Sheets
drive_search(q = "mimeType='application/vnd.google-apps.spreadsheet'") %>% head(3)

## ------------------------------------------------------------------------
drive_search(q = "fullText contains 'horsebean'") %>% head(3)

## ------------------------------------------------------------------------
drive_search(q = "sharedWithMe = true") %>% head(3)

## ------------------------------------------------------------------------
## this finds nothing because Drive's name search looks only at prefixes
drive_search(q = "name contains 'wts'")

## therefore we do regex matching on the R side
drive_search(pattern = "wts")

## ------------------------------------------------------------------------
drive_search(q = "name = '538-star-wars-survey'")

## ------------------------------------------------------------------------
drive_path("538-star-wars-survey")

## ----eval = FALSE--------------------------------------------------------
#  drive_path("538-star-wars-survey") %>%
#    confirm_single_file() %>%
#    drive_browse()
#  ## TO DO: I'd rather put drive_download() here, when it exists

