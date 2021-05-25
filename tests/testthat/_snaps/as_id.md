# as_id() errors for unanticipated input

    Code
      as_id(mean)
    Error <rlang_error>
      Don't know how to coerce an object of class <function> into a
      <drive_id>.

---

    Code
      as_id(1.2)
    Error <rlang_error>
      Don't know how to coerce an object of class <numeric> into a <drive_id>.

---

    Code
      as_id(1L)
    Error <rlang_error>
      Don't know how to coerce an object of class <integer> into a <drive_id>.

