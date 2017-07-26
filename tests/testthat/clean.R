#' ---
#' title: googledrive test clean
#' date: '`r format(Sys.time())`'
#' output: github_document
#' ---
#' This script aggregates the test-related clean code from all test files.
library(googledrive)
source('helper.R')
whoami <- drive_user()$user
whoami[c('displayName', 'emailAddress')]

## change this to TRUE when you are really ready to do this!
CLEAN <- TRUE
#' ## test-drive_cp.R
nm_ <- nm_fun("-TEST-drive-cp")
if (CLEAN) {
  drive_rm(c(
    nm_("i-am-a-folder"),
    nm_("not-unique-folder"),
    nm_("i-am-a-file")
  ))
}
#' ## test-drive_download.R
nm_ <- nm_fun("-TEST-drive-download")
if (CLEAN) {
  drive_rm(c(
    nm_("DESC"),
    nm_("DESC-doc")
  ))
}
#' ## test-drive_find.R
nm_ <- nm_fun("-TEST-drive-find")
if (CLEAN) {
  drive_rm(c(
    nm_("foo"),
    nm_("this-should-not-exist")
  ))
}
#' ## test-drive_get.R
nm_ <- nm_fun("-TEST-drive-get")
if (CLEAN) {
  files <- drive_find(nm_("thing0[1234]"))
  drive_rm(files)
}
#' ## test-drive_ls.R
nm_ <- nm_fun("-TEST-drive-ls")
if (CLEAN) {
  drive_rm(c(
    nm_("list-me"),
    nm_("this-should-not-exist")
  ))
}
#' ## test-drive_mkdir.R
nm_ <- nm_fun("-TEST-drive-mkdir")
if (CLEAN) {
  drive_rm(c(
    nm_("OMNI-PARENT"),
    nm_("I-live-in-root")
  ))
}
#' ## test-drive_mv.R
nm_ <- nm_fun("-TEST-drive-mv")
if (CLEAN) {
  drive_rm(c(
    nm_("move-files-into-me"),
    nm_("DESC"),
    nm_("DESC-renamed")
  ))
}
#' ## test-drive_publish.R
nm_ <- nm_fun("-TEST-drive-publish")
if (CLEAN) {
  drive_rm(c(
    nm_("foo_pdf"),
    nm_("foo_doc"),
    nm_("foo_sheet")
  ))
}
#' ## test-drive_share.R
nm_ <- nm_fun("-TEST-drive-share")
if (CLEAN) {
  drive_rm(c(
    nm_("mirrors-to-share"),
    nm_("DESC")
  ))
}
#' ## test-drive_trash.R
nm_ <- nm_fun("-TEST-drive-trash")
if (CLEAN) {
  drive_rm(nm_("foo"))
}
#' ## test-drive_update.R
nm_ <- nm_fun("-TEST-drive-update")
if (CLEAN) {
  drive_rm(c(
    nm_("update-me"),
    nm_("not-unique"),
    nm_("does-not-exist")
  ))
}
#' ## test-drive_upload.R
nm_ <- nm_fun("-TEST-drive-upload")
if (CLEAN) {
  drive_rm(c(
    nm_("upload-into-me"),
    nm_("DESCRIPTION")
  ))
}
