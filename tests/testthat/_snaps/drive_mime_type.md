# drive_mime_type() errors for invalid input

    Code
      drive_mime_type(1)
    Error <rlang_error>
      `type` must be character.

---

    Code
      drive_mime_type(dribble())
    Error <rlang_error>
      `type` must be character.

# drive_mime_type() errors for single unrecognized input

    Code
      drive_mime_type("nonsense")
    Error <rlang_error>
      Unrecognized `type`:
      x 'nonsense'

# drive_extension() errors for invalid input

    Code
      drive_extension(1)
    Error <simpleError>
      is.character(type) is not TRUE

---

    Code
      drive_extension(dribble())
    Error <simpleError>
      is.character(type) is not TRUE

# drive_extension() errors for single unrecognized input

    Code
      drive_extension("nonsense")
    Error <rlang_error>
      Unrecognized `type`:
      x 'nonsense'

