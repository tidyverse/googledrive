# drive_create() errors for bad input (before hitting Drive API)

    Code
      drive_create()
    Condition
      Error in `drive_create()`:
      ! `name` is absent but must be supplied.

---

    Code
      drive_create(letters)
    Condition
      Error in `drive_create()`:
      ! `name` must be a single string, not a character vector.

---

    Code
      drive_create(as_id("abc"))
    Condition
      Error in `drive_create()`:
      ! `name` must be a file name, not a Drive ID.
      i Did you mean to pass the ID as `path`?

# drive_create() errors if parent path does not exist

    Code
      drive_create("a", path = "qweruiop")
    Condition
      Error in `drive_create()`:
      ! Parent specified via `path` is invalid:
      x Does not exist.

# drive_create() errors if parent exists but is not a folder

    Code
      drive_create("a", path = x)
    Condition
      Error in `drive_create()`:
      ! Parent specified via `path` is invalid:
      x Is neither a folder nor a shared drive.

