# drive_upload() detects non-existent file

    Code
      drive_upload("no-such-file", "File does not exist")
    Condition
      Error in `drive_upload()`:
      ! No file exists at the local `media` path:
      x 'no-such-file'

