# drive_put() works

    Code
      writeLines(first_put)
    Output
      i No pre-existing Drive file at this path. Calling `drive_upload()`.
      Local file:
      {RANDOM}
      Uploaded into Drive file:
      {RANDOM}
      With MIME type:
      * 'text/plain'

---

    Code
      writeLines(second_put)
    Output
      i A Drive file already exists at this path. Calling `drive_update()`.
      File updated:
      {RANDOM}

