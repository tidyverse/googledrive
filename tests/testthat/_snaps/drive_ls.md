# drive_ls() errors if `path` does not exist

    Code
      drive_ls(nm_("this-should-not-exist"))
    Condition
      Error in `as_parent()`:
      ! Parent specified via `path` is invalid:
      x Does not exist.

# drive_ls() list contents of the target of a folder shortcut

    Code
      write_utf8(drive_ls_message)
    Output
      i Parent specified via `path` is a shortcut; resolving to its target folder
      i Resolved 1 shortcut found in 1 file:
      * '{shortcut_name}' <id: {FILE_ID}> -> '{target_name}' <id: {FILE_ID}>

