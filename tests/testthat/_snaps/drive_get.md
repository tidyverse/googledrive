# drive_get() 'no input' edge cases

    Code
      drive_get(id = NA_character_)
    Error <rlang_error>
      Can't `drive_get()` a file when `id` is `NA`.

---

    Code
      drive_get(id = "")
    Error <rlang_error>
      A <drive_id> can't be the empty string.

---

    Code
      dat <- drive_get("")
    Message <cliMessage>
      ! Problem with 1 path: path is empty string
      ! No path resolved to exactly 1 file.

