# drive_put() works

    Code
      writeLines(first_put)
    Output
      i No pre-existing Drive file at this path. Calling `drive_upload()`.
      Local file:
      * '{local_file}'
      Uploaded into Drive file:
      * {put_file} <id: {FILE_ID}>
      With MIME type:
      * 'text/plain'

---

    Code
      writeLines(second_put)
    Output
      i A Drive file already exists at this path. Calling `drive_update()`.
      File updated:
      * {put_file} <id: {FILE_ID}>

