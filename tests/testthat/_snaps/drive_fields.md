# drive_fields() admits it only knows about Files fields

    Code
      out <- drive_fields(x, resource = "foo")
    Message
      ! Currently only fields for the 'files' resource can be checked for validity.
        Nothing done.

# drive_fields() detects bad fields

    Code
      out <- drive_fields(c("name", "parents", "ownedByMe", "pancakes!"))
    Condition
      Warning:
      Omitting fields that are not recognized as part of the Files resource:
      * 'pancakes!'

# drive_fields() checks type of `fields`

    Code
      drive_fields(1)
    Condition
      Error in `drive_fields()`:
      ! `fields` must be a character vector, not the number 1.

