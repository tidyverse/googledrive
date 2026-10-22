# drive_get() checks `corpus` (before hitting Drive API)

    Code
      drive_get("foo", corpus = "nope")
    Condition
      Error in `drive_get()`:
      ! Invalid value for `corpus`:
      x 'nope'
      These are the only acceptable values:
      * 'user'
      * 'drive'
      * 'allDrives'
      * 'domain'

---

    Code
      drive_get("foo", corpus = "drive")
    Condition
      Error in `drive_get()`:
      ! When `corpus = "drive"`, you must also specify the `shared_drive`.

# drive_get() checks `path` and `id` (before hitting Drive API)

    Code
      drive_get(path = 1)
    Condition
      Error in `drive_get()`:
      ! `path` must be a character vector or `NULL`, not the number 1.

---

    Code
      drive_get(id = 1)
    Condition
      Error in `drive_get()`:
      ! `id` must be a character vector or `NULL`, not the number 1.

---

    Code
      drive_get("/abc")
    Condition
      Error in `drive_get()`:
      ! googledrive does not allow paths to start with `/`

---

    Code
      drive_get(id = c("abc", NA))
    Condition
      Error in `drive_get()`:
      ! `id` can't contain `NA`.

# drive_get() 'no input' edge cases

    Code
      drive_get(id = NA_character_)
    Condition
      Error in `drive_get()`:
      ! `id` can't contain `NA`.

---

    Code
      drive_get(id = "")
    Condition
      Error in `validate_drive_id()`:
      ! A <drive_id> must match this regular expression: `^[a-zA-Z0-9_-]+$`
      Invalid input:
      x '""'

---

    Code
      dat <- drive_get("")
    Message
      ! Problem with 1 path: path is empty string
      ! No path resolved to exactly 1 file.

