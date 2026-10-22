# drive_endpoint() checks `i`

    Code
      drive_endpoint(c("a", "b"))
    Condition
      Error in `drive_endpoint()`:
      ! `i` must be a single string or a whole number, not a character vector.

---

    Code
      drive_endpoint(1.5)
    Condition
      Error in `drive_endpoint()`:
      ! `i` must be a single string or a whole number, not the number 1.5.

---

    Code
      drive_endpoint(TRUE)
    Condition
      Error in `drive_endpoint()`:
      ! `i` must be a single string or a whole number, not `TRUE`.

