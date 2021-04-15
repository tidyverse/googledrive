# drive_get() 'no input' edge cases

    Code
      drive_get(id = NA_character_)
    Error <simpleError>
      File ids must not be NA and cannot be the empty string.

---

    Code
      drive_get(id = "")
    Error <simpleError>
      File ids must not be NA and cannot be the empty string.

