# warn_for_verbose() warns for `verbose = FALSE` w/ good message

    Code
      drive_something()
    Warning <lifecycle_warning_deprecated>
      The `verbose` argument of `drive_something()` is deprecated as of googledrive 2.0.0.
      Set `options(googledrive_quiet = TRUE)` to suppress all googledrive messages.
      For finer control, use `local_drive_quiet()` or `with_drive_quiet()`.
      googledrive's `verbose` argument will be removed in the future.

# warn_for_verbose(FALSE) makes googledrive quiet, in scope

    Code
      message_glue("chatty before")
    Message <simpleMessage>
      chatty before
    Code
      drive_something()
      message_glue("chatty after")
    Message <simpleMessage>
      chatty after

