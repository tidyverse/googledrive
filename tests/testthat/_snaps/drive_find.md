# drive_find() errors for nonsense in `n_max`

    Code
      drive_find(n_max = "a")
    Condition
      Error in `drive_find()`:
      ! is.numeric(n_max) is not TRUE

---

    Code
      drive_find(n_max = 1:3)
    Condition
      Error in `drive_find()`:
      ! length(n_max) == 1 is not TRUE

---

    Code
      drive_find(n_max = -2)
    Condition
      Error in `drive_find()`:
      ! n_max >= 0 is not TRUE

