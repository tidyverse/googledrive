## in a session and directory where you are willing to authenticate or have
## an existing .httr-oauth, do this:
## token <- drive_auth()
## make sure you are happy with this user running tests!
## folders and files will be created AND DELETED!
## drive_user()
## saveRDS(token, rprojroot::find_testthat_root_file("testing-token.rds"))
drive_auth(rprojroot::find_testthat_root_file("testing-token.rds"))
