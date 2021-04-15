# drive_create() errors for bad input (before hitting Drive API)

    Code
      drive_create()
    Error <simpleError>
      argument "name" is missing, with no default

---

    Code
      drive_create(letters)
    Error <simpleError>
      is_string(name) is not TRUE

# drive_create() errors if parent path does not exist

    Code
      drive_create("a", path = "qweruiop")
    Error <simpleError>
      Parent specified via `path` does not exist.

# drive_create() errors if parent exists but is not a folder

    Code
      drive_create("a", path = x)
    Error <simpleError>
      Requested parent `path` is invalid: neither a folder nor a shared drive.

# drive_create() catches invalid parameters

    Code
      (expect_error(drive_create("hi", bunny = "foofoo"), class = "gargle_error_bad_params")
      )
    Output
      <error/gargle_error_bad_params>
      These parameters are unknown:
      * bunny

