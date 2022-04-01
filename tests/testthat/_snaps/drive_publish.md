# drive_publish() fails for non-native file type

    Code
      drive_publish(drive_pdf)
    Condition
      Error in `drive_change_publish()`:
      ! Only native Google files can be published.
      `file` includes a file with non-native MIME type
      * 'foo_pdf-TEST-drive_publish': 'application/pdf'
      i You can use `drive_share()` to change a file's sharing permissions.

