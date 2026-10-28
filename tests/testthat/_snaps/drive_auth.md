# drive_auth_configure works

    Code
      drive_auth_configure(client = gargle::gargle_client(), path = "PATH")
    Condition
      Error in `drive_auth_configure()`:
      ! Must supply exactly one of `client` or `path`, not both

---

    Code
      drive_auth_configure(path = 1)
    Condition
      Error in `drive_auth_configure()`:
      ! `path` must be a single string, not the number 1.

---

    Code
      drive_auth_configure(api_key = 1)
    Condition
      Error in `drive_auth_configure()`:
      ! `api_key` must be a single string or `NULL`, not the number 1.

---

    Code
      drive_auth_configure(client = "a")
    Condition
      Error in `drive_auth_configure()`:
      ! `client` must be a <gargle_oauth_client> or `NULL`, not the string "a".

# drive_scopes() reveals Drive scopes

    Code
      drive_scopes()
    Output
                                                          drive 
                        "https://www.googleapis.com/auth/drive" 
                                                           full 
                        "https://www.googleapis.com/auth/drive" 
                                                 drive.readonly 
               "https://www.googleapis.com/auth/drive.readonly" 
                                                     drive.file 
                   "https://www.googleapis.com/auth/drive.file" 
                                                  drive.appdata 
                "https://www.googleapis.com/auth/drive.appdata" 
                                                 drive.metadata 
               "https://www.googleapis.com/auth/drive.metadata" 
                                        drive.metadata.readonly 
      "https://www.googleapis.com/auth/drive.metadata.readonly" 
                                          drive.photos.readonly 
        "https://www.googleapis.com/auth/drive.photos.readonly" 
                                                  drive.scripts 
                "https://www.googleapis.com/auth/drive.scripts" 

# drive_token_write() and drive_token_read() check inputs

    Code
      drive_token_write("nope", path = "x.rds")
    Condition
      Error in `drive_token_write()`:
      ! `token` must be a <Token2.0> or the result of `drive_token()`, not the string "nope".

---

    Code
      drive_token_read(path = "does-not-exist.rds")
    Condition
      Error in `drive_token_read()`:
      ! Can't find token file at 'does-not-exist.rds'.

