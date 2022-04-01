# shortcut_create() works

    Code
      write_utf8(shortcut_create_message)
    Output
      Created Drive file:
      * '{sc_name}' <id: {FILE_ID}>
      With MIME type:
      * 'application/vnd.google-apps.shortcut'

# shortcut_create() requires `name` to control `overwrite`

    Code
      shortcut_create(nm_("top-level-file"), overwrite = FALSE)
    Condition
      Error in `shortcut_create()`:
      ! You must specify the shortcut's `name` in order to specify `overwrite` behaviour.

