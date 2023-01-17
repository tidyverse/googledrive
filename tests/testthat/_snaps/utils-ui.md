# warn_for_verbose() warns for `verbose = FALSE` w/ good message

    Code
      drive_something()
    Condition
      Warning:
      The `verbose` argument of `drive_something()` is deprecated as of googledrive 2.0.0.
      i Set `options(googledrive_quiet = TRUE)` to suppress all googledrive messages.
      i For finer control, use `local_drive_quiet()` or `with_drive_quiet()`.
      i googledrive's `verbose` argument will be removed in the future.

# warn_for_verbose(FALSE) makes googledrive quiet, in scope

    Code
      drive_bullets("chatty before")
    Message
      chatty before
    Code
      drive_something()
      drive_bullets("chatty after")
    Message
      chatty after

