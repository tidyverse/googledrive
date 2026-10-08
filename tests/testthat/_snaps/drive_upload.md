# drive_upload() detects non-existent file

    Code
      drive_upload("no-such-file", "File does not exist")
    Condition
      Error in `drive_upload()`:
      ! No file exists at the local `media` path:
      x 'no-such-file'

# drive_upload() can convert local markdown to a Doc

    Code
      write_utf8(drive_upload_message)
    Output
      Local file:
      * '{file_to_upload}'
      Uploaded into Drive file:
      * '{upload_name}' <id: {FILE_ID}>
      With MIME type:
      * 'application/vnd.google-apps.document'

