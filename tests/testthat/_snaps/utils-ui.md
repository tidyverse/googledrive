# bulletize() works

    Code
      cli::cli_bullets(bulletize(letters))
    Message <cliMessage>
      * a
      * b
      * c
      * d
      * e
        ... and 21 more

---

    Code
      cli::cli_bullets(bulletize(letters, bullet = "x"))
    Message <cliMessage>
      x a
      x b
      x c
      x d
      x e
        ... and 21 more

---

    Code
      cli::cli_bullets(bulletize(letters, n_show = 2))
    Message <cliMessage>
      * a
      * b
        ... and 24 more

---

    Code
      cli::cli_bullets(bulletize(letters[1:6]))
    Message <cliMessage>
      * a
      * b
      * c
      * d
      * e
      * f

---

    Code
      cli::cli_bullets(bulletize(letters[1:7]))
    Message <cliMessage>
      * a
      * b
      * c
      * d
      * e
      * f
      * g

---

    Code
      cli::cli_bullets(bulletize(letters[1:8]))
    Message <cliMessage>
      * a
      * b
      * c
      * d
      * e
        ... and 3 more

---

    Code
      cli::cli_bullets(bulletize(letters[1:6], n_fudge = 0))
    Message <cliMessage>
      * a
      * b
      * c
      * d
      * e
        ... and 1 more

---

    Code
      cli::cli_bullets(bulletize(letters[1:8], n_fudge = 3))
    Message <cliMessage>
      * a
      * b
      * c
      * d
      * e
      * f
      * g
      * h

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
      drive_bullets("chatty before")
    Message <cliMessage>
      chatty before
    Code
      drive_something()
      drive_bullets("chatty after")
    Message <cliMessage>
      chatty after

