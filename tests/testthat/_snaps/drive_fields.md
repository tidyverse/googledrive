# drive_fields() admits it only knows about Files fields

    Code
      out <- drive_fields(x, resource = "foo")
    Message <cliMessage>
      ! Currently only fields for the 'files' resource can be checked for validity.
        Nothing done.

# drive_fields() detects bad fields

    Code
      out <- drive_fields(c("name", "parents", "ownedByMe", "pancakes!"))
    Warning <warning>
      Omitting fields that are not recognized as part of the Files resource:
      * 'pancakes!'

