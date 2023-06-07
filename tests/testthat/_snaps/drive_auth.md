# drive_auth_configure works

    Code
      drive_auth_configure(client = gargle::gargle_client(), path = "PATH")
    Condition
      Error in `drive_auth_configure()`:
      ! Must supply exactly one of `client` or `path`, not both

# drive_scopes() reveals Drive scopes

    Code
      drive_scopes()
    Output
                                                           full 
                        "https://www.googleapis.com/auth/drive" 
                                                          drive 
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

