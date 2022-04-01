# drive_download() won't overwrite existing file

    Code
      withr::with_dir(tmpdir, drive_download(dribble(), path = precious_filepath))
    Condition
      Error in `drive_download()`:
      ! Local `path` already exists and overwrite is `FALSE`:
      * 'precious-TEST-drive_download.txt'

# drive_download() downloads a file and adds local_path column

    Code
      write_utf8(drive_download_message)
    Output
      File downloaded:
      * '{file_to_download}' <id: {FILE_ID}>
      Saved locally as:
      * '{download_filepath}'

# drive_download() errors if file does not exist on Drive

    Code
      drive_download(nm_("this-should-not-exist"))
    Condition
      Error in `confirm_single_file()`:
      ! `file` does not identify at least one Drive file.

# drive_download() converts with explicit `type`

    Code
      write_utf8(drive_download_message)
    Output
      File downloaded:
      * '{file_to_download}' <id: {FILE_ID}>
      Saved locally as:
      * '{download_filename}'

# drive_download() converts with type implicit in `path`

    Code
      write_utf8(drive_download_message)
    Output
      File downloaded:
      * '{file_to_download}' <id: {FILE_ID}>
      Saved locally as:
      * '{download_filename}'

# drive_download() converts using default MIME type, if necessary

    Code
      write_utf8(drive_download_message)
    Output
      File downloaded:
      * '{file_to_download}' <id: {FILE_ID}>
      Saved locally as:
      * '{download_filename}'

