# drive_download() downloads a file and adds local_path column

    Code
      out <- drive_download(nm_("DESC"), path = local_path, overwrite = TRUE)
    Message <simpleMessage>
      File downloaded:
        * DESC-TEST-drive-download
      Saved locally as:
        * DESC-TEST-drive-download.txt

# drive_download() converts with explicit `type`

    Code
      drive_download(file = nm_("DESC-doc"), type = "docx")
    Message <simpleMessage>
      File downloaded:
        * DESC-doc-TEST-drive-download
      Saved locally as:
        * DESC-doc-TEST-drive-download.docx

# drive_download() converts with type implicit in `path`

    Code
      drive_download(file = nm_("DESC-doc"), path = nm)
    Message <simpleMessage>
      File downloaded:
        * DESC-doc-TEST-drive-download
      Saved locally as:
        * DESC-doc-TEST-drive-download.docx

# drive_download() converts using default MIME type, if necessary

    Code
      drive_download(file = nm_("DESC-doc"))
    Message <simpleMessage>
      File downloaded:
        * DESC-doc-TEST-drive-download
      Saved locally as:
        * DESC-doc-TEST-drive-download.docx

