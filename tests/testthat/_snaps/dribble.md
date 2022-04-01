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
    Condition
      Error:
      ! `x` must be a list

# validate_dribble() checks class, var names, var types

    Code
      validate_dribble("a")
    Condition
      Error in `validate_dribble()`:
      ! inherits(x, "dribble") is not TRUE

---

    Code
      validate_dribble(d)
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. This column has the wrong type:
      * `id`

---

    Code
      validate_dribble(d)
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. These columns have the wrong type:
      * `name`
      * `id`

---

    Code
      validate_dribble(d)
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. This required column is missing:
      * `name`

---

    Code
      validate_dribble(d)
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. These required columns are missing:
      * `name`
      * `id`

---

    Code
      validate_dribble(d)
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. Can't confirm `kind = "drive#file"` or `kind = "drive#drive"` for all elements of the `drive_resource` column.

# dribble nrow checkers work

    Code
      confirm_single_file(d)
    Condition
      Error in `confirm_single_file()`:
      ! `d` does not identify at least one Drive file.

---

    Code
      confirm_some_files(d)
    Condition
      Error in `confirm_some_files()`:
      ! `d` does not identify at least one Drive file.

---

    Code
      confirm_single_file(d)
    Condition
      Error in `confirm_single_file()`:
      ! `d` identifies more than one Drive file.

# as_dribble() default method handles unsuitable input

    Code
      as_dribble(1.3)
    Condition
      Error in `as_dribble()`:
      ! Don't know how to coerce an object of class <numeric> into a <dribble>.

---

    Code
      as_dribble(TRUE)
    Condition
      Error in `as_dribble()`:
      ! Don't know how to coerce an object of class <logical> into a <dribble>.

# as_dribble.list() catches bad input

    Code
      as_dribble(list(drib_lst))
    Condition
      Error in `as_dribble.list()`:
      ! map_lgl(x, ~all(required_nms %in% names(.x))) is not TRUE

---

    Code
      as_dribble(list(drib_lst))
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. Can't confirm `kind = "drive#file"` or `kind = "drive#drive"` for all elements of the `drive_resource` column.

# as_parent() throws specific errors

    Code
      foo <- d[0, ]
      as_parent(foo)
    Condition
      Error in `as_parent()`:
      ! Parent specified via `foo` is invalid:
      x Does not exist.

---

    Code
      foo <- d
      as_parent(foo)
    Condition
      Error in `as_parent()`:
      ! Parent specified via `foo` is invalid:
      x Doesn't uniquely identify exactly one folder or shared drive.

---

    Code
      foo <- d[1, ]
      as_parent(foo)
    Condition
      Error in `as_parent()`:
      ! Parent specified via `foo` is invalid:
      x Is neither a folder nor a shared drive.

