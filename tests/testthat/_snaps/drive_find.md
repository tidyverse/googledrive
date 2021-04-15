# drive_find() errors for nonsense in `n_max`

    Code
      drive_find(n_max = "a")
    Error <simpleError>
      is.numeric(n_max) is not TRUE

---

    Code
      drive_find(n_max = 1:3)
    Error <simpleError>
      length(n_max) == 1 is not TRUE

---

    Code
      drive_find(n_max = -2)
    Error <simpleError>
      n_max >= 0 is not TRUE

