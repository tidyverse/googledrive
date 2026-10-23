# drive_ls() checks `recursive` (before hitting Drive API)

    Code
      drive_ls(recursive = "yes")
    Condition
      Error in `drive_ls()`:
      ! `recursive` must be `TRUE` or `FALSE`, not the string "yes".

# drive_ls() reports itself for errors from drive_find() args

    Code
      drive_ls(corpus = "nope")
    Condition
      Error in `drive_ls()`:
      ! Invalid value for `corpus`:
      x 'nope'
      These are the only acceptable values:
      * 'user'
      * 'drive'
      * 'allDrives'
      * 'domain'

---

    Code
      drive_ls(n_max = -1)
    Condition
      Error in `drive_ls()`:
      ! `n_max` must be a whole number larger than or equal to 0, not the number -1.

# drive_ls() errors if `path` does not exist

    Code
      drive_ls(nm_("this-should-not-exist"))
    Condition
      Error in `drive_ls()`:
      ! Parent specified via `path` is invalid:
      x Does not exist.

# drive_ls() list contents of the target of a folder shortcut

    Code
      write_utf8(drive_ls_message)
    Output
      i Parent specified via `path` is a shortcut; resolving to its target folder
      i Resolved 1 shortcut found in 1 file:
      * '{shortcut_name}' <id: {FILE_ID}> -> '{target_name}' <id: {FILE_ID}>

