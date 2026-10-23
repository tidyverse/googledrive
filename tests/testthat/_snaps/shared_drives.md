# new_corpus() checks type and length, if not-NULL

    Code
      new_corpus(driveId = c("1", "2"))
    Condition
      Error in `new_corpus()`:
      ! `driveId` must be a single string, not a character vector.

---

    Code
      new_corpus(corpora = c("a", "b"))
    Condition
      Error in `new_corpus()`:
      ! `corpora` must be a single string, not a character vector.

---

    Code
      new_corpus(includeItemsFromAllDrives = c(TRUE, FALSE))
    Condition
      Error in `new_corpus()`:
      ! `includeItemsFromAllDrives` must be `TRUE` or `FALSE`, not a logical vector.

# `corpora` is checked for validity

    Code
      shared_drive_params(corpora = "foo")
    Condition
      Error:
      ! `corpus` must be one of "user", "drive", "allDrives", or "domain", not "foo".

# `corpora = "drive"` requires shared drive specification

    Code
      shared_drive_params(corpora = "drive")
    Condition
      Error:
      ! When `corpus = "drive"`, you must also specify the `shared_drive`.

# `corpora != "drive"` rejects shared drive specification

    Code
      shared_drive_params(corpora = "user", driveId = "123")
    Condition
      Error:
      ! When `corpus != "drive"`, you must not specify a `shared_drive`.

# shared_drive_find() checks `pattern` (before hitting Drive API)

    Code
      shared_drive_find(pattern = letters)
    Condition
      Error in `shared_drive_find()`:
      ! `pattern` must be a single string or `NULL`, not a character vector.

---

    Code
      shared_drive_find(pattern = as_id("abc"))
    Condition
      Error in `shared_drive_find()`:
      ! `pattern` must be a regular expression, not a Drive ID.
      i To get a shared drive by its ID, use `shared_drive_get(id = )`.

# shared_drive_find() checks `n_max` (before hitting Drive API)

    Code
      shared_drive_find(n_max = -1)
    Condition
      Error in `shared_drive_find()`:
      ! `n_max` must be a whole number larger than or equal to 0, not the number -1.

# shared_drive_get() checks `name` and `id` (before hitting Drive API)

    Code
      shared_drive_get(c("a", NA))
    Condition
      Error in `shared_drive_get()`:
      ! `name` can't contain NA values.

---

    Code
      shared_drive_get(id = 1)
    Condition
      Error in `shared_drive_get()`:
      ! `id` must be a character vector, not the number 1.

---

    Code
      shared_drive_get(id = c("abc", NA))
    Condition
      Error in `shared_drive_get()`:
      ! `id` can't contain NA values.

