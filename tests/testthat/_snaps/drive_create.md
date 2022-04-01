# drive_create() errors for bad input (before hitting Drive API)

    Code
      drive_create()
    Condition
      Error in `is_string()`:
      ! argument "name" is missing, with no default

---

    Code
      drive_create(letters)
    Condition
      Error in `drive_create()`:
      ! is_string(name) is not TRUE

# drive_create() errors if parent path does not exist

    Code
      drive_create("a", path = "qweruiop")
    Condition
      Error in `as_parent()`:
      ! Parent specified via `path` is invalid:
      x Does not exist.

# drive_create() errors if parent exists but is not a folder

    Code
      drive_create("a", path = x)
    Condition
      Error in `as_parent()`:
      ! Parent specified via `path` is invalid:
      x Is neither a folder nor a shared drive.

