# new_corpus() checks type and length, if not-NULL

    Code
      new_corpus(driveId = c("1", "2"))
    Condition
      Error in `new_corpus()`:
      ! length(driveId) == 1 is not TRUE

---

    Code
      new_corpus(corpora = c("a", "b"))
    Condition
      Error in `new_corpus()`:
      ! is_string(corpora) is not TRUE

---

    Code
      new_corpus(includeItemsFromAllDrives = c(TRUE, FALSE))
    Condition
      Error in `new_corpus()`:
      ! length(includeItemsFromAllDrives) == 1 is not TRUE

# `corpora` is checked for validity

    Code
      shared_drive_params(corpora = "foo")
    Condition
      Error in `validate_corpora()`:
      ! Invalid value for `corpus`:
      x 'foo'
      These are the only acceptable values:
      * 'user'
      * 'drive'
      * 'allDrives'
      * 'domain'

# `corpora = "drive"` requires shared drive specification

    Code
      shared_drive_params(corpora = "drive")
    Condition
      Error in `rationalize_corpus()`:
      ! When `corpus = "drive"`, you must also specify the `shared_drive`.

# `corpora != "drive"` rejects shared drive specification

    Code
      shared_drive_params(corpora = "user", driveId = "123")
    Condition
      Error in `rationalize_corpus()`:
      ! When `corpus != "drive"`, you must not specify a `shared_drive`.

