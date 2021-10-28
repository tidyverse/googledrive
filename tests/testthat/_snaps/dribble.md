# tbl_sum.dribble method works

    Code
      print(d)
    Output
      # A dribble: 2 x 3
        name  id       drive_resource  
        <chr> <drv_id> <list>          
      1 a     b        <named list [1]>
      2 b     a        <named list [1]>

# new_dribble() requires a list and adds the dribble class

    Code
      new_dribble(1:3)
    Error <simpleError>
      `x` must be a list

# validate_dribble() checks class, var names, var types

    Code
      validate_dribble("a")
    Error <simpleError>
      inherits(x, "dribble") is not TRUE

---

    Code
      validate_dribble(d)
    Error <rlang_error>
      Invalid <dribble>. This column has the wrong type:
      * `id`

---

    Code
      validate_dribble(d)
    Error <rlang_error>
      Invalid <dribble>. These columns have the wrong type:
      * `name`
      * `id`

---

    Code
      validate_dribble(d)
    Error <rlang_error>
      Invalid <dribble>. This required column is missing:
      * `name`

---

    Code
      validate_dribble(d)
    Error <rlang_error>
      Invalid <dribble>. These required columns are missing:
      * `name`
      * `id`

---

    Code
      validate_dribble(d)
    Error <rlang_error>
      Invalid <dribble>. Can't confirm `kind = "drive#file"` or `kind = "drive#drive"` for all elements of the `drive_resource` column.

# dribble nrow checkers work

    Code
      confirm_single_file(d)
    Error <rlang_error>
      `d` does not identify at least one Drive file.

---

    Code
      confirm_some_files(d)
    Error <rlang_error>
      `d` does not identify at least one Drive file.

---

    Code
      confirm_single_file(d)
    Error <rlang_error>
      `d` identifies more than one Drive file.

# as_dribble() default method handles unsuitable input

    Code
      as_dribble(1.3)
    Error <rlang_error>
      Don't know how to coerce an object of class <numeric> into a <dribble>.

---

    Code
      as_dribble(TRUE)
    Error <rlang_error>
      Don't know how to coerce an object of class <logical> into a <dribble>.

# as_dribble.list() catches bad input

    Code
      as_dribble(list(drib_lst))
    Error <simpleError>
      map_lgl(x, ~all(required_nms %in% names(.x))) is not TRUE

---

    Code
      as_dribble(list(drib_lst))
    Error <rlang_error>
      Invalid <dribble>. Can't confirm `kind = "drive#file"` or `kind = "drive#drive"` for all elements of the `drive_resource` column.

# as_parent() throws specific errors

    Code
      foo <- d[0, ]
      as_parent(foo)
    Error <rlang_error>
      Parent specified via `foo` is invalid:
      x Does not exist.

---

    Code
      foo <- d
      as_parent(foo)
    Error <rlang_error>
      Parent specified via `foo` is invalid:
      x Doesn't uniquely identify exactly one folder or shared drive.

---

    Code
      foo <- d[1, ]
      as_parent(foo)
    Error <rlang_error>
      Parent specified via `foo` is invalid:
      x Is neither a folder nor a shared drive.

