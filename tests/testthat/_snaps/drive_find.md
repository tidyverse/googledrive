# drive_find() checks `pattern` (before hitting Drive API)

    Code
      drive_find(pattern = letters)
    Condition
      Error in `drive_find()`:
      ! `pattern` must be a single string or `NULL`, not a character vector.

---

    Code
      drive_find(pattern = as_id("abc"))
    Condition
      Error in `drive_find()`:
      ! `pattern` must be a regular expression, not a Drive ID.
      i To get a file by its ID, use `drive_get(id = )`.

# drive_find() checks `corpus` (before hitting Drive API)

    Code
      drive_find(corpus = c("user", "domain"))
    Condition
      Error in `drive_find()`:
      ! `corpus` must be a single string or `NULL`, not a character vector.

---

    Code
      drive_find(corpus = "foo")
    Condition
      Error in `drive_find()`:
      ! Invalid value for `corpus`:
      x 'foo'
      These are the only acceptable values:
      * 'user'
      * 'drive'
      * 'allDrives'
      * 'domain'

---

    Code
      drive_find(corpus = "drive")
    Condition
      Error in `drive_find()`:
      ! When `corpus = "drive"`, you must also specify the `shared_drive`.

# drive_find() checks `shared_drive` (before hitting Drive API)

    Code
      drive_find(shared_drive = two_drives)
    Condition
      Error in `drive_find()`:
      ! `shared_drive` must identify exactly one shared drive, not 2.

# drive_find() errors for nonsense in `n_max`

    Code
      drive_find(n_max = "a")
    Condition
      Error in `drive_find()`:
      ! is.numeric(n_max) is not TRUE

---

    Code
      drive_find(n_max = 1:3)
    Condition
      Error in `drive_find()`:
      ! length(n_max) == 1 is not TRUE

---

    Code
      drive_find(n_max = -2)
    Condition
      Error in `drive_find()`:
      ! n_max >= 0 is not TRUE

