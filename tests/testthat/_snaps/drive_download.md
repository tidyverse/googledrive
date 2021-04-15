# drive_download() won't overwrite existing file

    Path exists and overwrite is FALSE:
      * precious-TEST-drive-download.txt

# drive_download() downloads a file and adds local_path column

    Code
      withr::with_dir(tmpdir, out <- drive_download(nm_("DESC"), path = download_filepath))
    Message <simpleMessage>
      File downloaded:
        * DESC-TEST-drive-download
      Saved locally as:
        * DESC-TEST-drive-download.txt

# drive_download() converts with explicit `type`

    Code
      withr::with_dir(tmpdir, drive_download(file = nm_("DESC-doc"), type = "docx"))
    Message <simpleMessage>
      File downloaded:
        * DESC-doc-TEST-drive-download
      Saved locally as:
        * DESC-doc-TEST-drive-download.docx

# drive_download() converts with type implicit in `path`

    Code
      withr::with_dir(tmpdir, drive_download(file = nm_("DESC-doc"), path = download_filename))
    Message <simpleMessage>
      File downloaded:
        * DESC-doc-TEST-drive-download
      Saved locally as:
        * DESC-doc-TEST-drive-download.docx

# drive_download() converts using default MIME type, if necessary

    Code
      withr::with_dir(tmpdir, drive_download(file = nm_("DESC-doc")))
    Message <simpleMessage>
      File downloaded:
        * DESC-doc-TEST-drive-download
      Saved locally as:
        * DESC-doc-TEST-drive-download.docx

