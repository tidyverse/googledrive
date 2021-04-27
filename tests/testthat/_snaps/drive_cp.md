# drive_cp() can copy file in place

    Code
      writeLines(drive_cp_message)
    Output
      Original file:
      * i-am-a-file-TEST-drive-cp <id: {FILE_ID}>
      Copied to file:
      * {cp_name} <id: {FILE_ID}>

# drive_cp() can copy a file into a different folder

    Code
      writeLines(drive_cp_message)
    Output
      Original file:
      * i-am-a-file-TEST-drive-cp <id: {FILE_ID}>
      Copied to file:
      * ~/i-am-a-folder-TEST-drive-cp/{cp_name} <id: {FILE_ID}>

# drive_cp() doesn't tolerate ambiguity in `path`

    Code
      drive_cp(file, nm_("i-am-a-folder"))
    Error <simpleError>
      Unclear if `path` specifies parent folder or full path
      to the new file, including its name. See ?as_dribble() for details.

# drive_cp() errors if asked to copy a folder

    Code
      drive_cp(nm_("i-am-a-folder"))
    Error <simpleError>
      The Drive API does not copy folders or shared drives.

# drive_cp() takes name, assumes path is folder if both are specified

    Code
      writeLines(drive_cp_message)
    Output
      Original file:
      * i-am-a-file-TEST-drive-cp <id: {FILE_ID}>
      Copied to file:
      * ~/i-am-a-folder-TEST-drive-cp/{cp_name} <id: {FILE_ID}>

---

    Code
      file_cp <- drive_cp(nm_("i-am-a-file"), path = nm_("file-name"), name = nm_(
        "file-name"))
    Error <simpleError>
      Parent specified via `path` does not exist.

---

    Code
      file_cp <- drive_cp(nm_("i-am-a-file"), append_slash(nm_("not-unique-folder")))
    Error <simpleError>
      Parent specified via `path` doesn't uniquely identify exactly one folder or shared drive.

