# as_id() errors for unanticipated input

    Code
      as_id(mean)
    Error <simpleError>
      Don't know how to coerce object of class <function> into a drive_id

---

    Code
      as_id(1.2)
    Error <simpleError>
      Don't know how to coerce object of class <numeric> into a drive_id

---

    Code
      as_id(1L)
    Error <simpleError>
      Don't know how to coerce object of class <integer> into a drive_id

