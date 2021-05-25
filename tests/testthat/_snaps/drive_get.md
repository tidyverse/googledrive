# drive_get() 'no input' edge cases

    Code
      drive_get(id = NA_character_)
    Error <rlang_error>
      File ids must not be `NA` and cannot be the empty string.

---

    Code
      drive_get(id = "")
    Error <rlang_error>
      File ids must not be `NA` and cannot be the empty string.

