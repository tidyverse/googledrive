# drive_mime_type() errors for invalid input

    Code
      drive_mime_type(1)
    Condition
      Error in `drive_mime_type()`:
      ! `type` must be a character vector, not the number 1.

---

    Code
      drive_mime_type(dribble())
    Condition
      Error in `drive_mime_type()`:
      ! `type` must be a character vector, not a <dribble> object.

# drive_mime_type() errors for single unrecognized input

    Code
      drive_mime_type("nonsense")
    Condition
      Error in `drive_mime_type()`:
      ! Unrecognized `type`:
      x 'nonsense'

# drive_extension() errors for invalid input

    Code
      drive_extension(1)
    Condition
      Error in `drive_extension()`:
      ! `type` must be a character vector, not the number 1.

---

    Code
      drive_extension(dribble())
    Condition
      Error in `drive_extension()`:
      ! `type` must be a character vector, not a <dribble> object.

# drive_extension() errors for single unrecognized input

    Code
      drive_extension("nonsense")
    Condition
      Error in `drive_mime_type()`:
      ! Unrecognized `type`:
      x 'nonsense'

