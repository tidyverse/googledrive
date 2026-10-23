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
      * `id` must be a character vector, not an empty numeric vector.

---

    Code
      validate_dribble(d)
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. These columns have the wrong type:
      * `name` must be a character vector, not an empty logical vector.
      * `id` must be a character vector, not an empty numeric vector.

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

# dribble predicates require a dribble

    Code
      no_file("a")
    Condition
      Error in `no_file()`:
      ! `d` must be a <dribble>, not the string "a".

---

    Code
      is_folder(data.frame(x = 1))
    Condition
      Error in `is_folder()`:
      ! `d` must be a <dribble>, not a <data.frame> object.

# dribble nrow checkers work

    Code
      confirm_single_file(d)
    Condition
      Error:
      ! `d` does not identify at least one Drive file.

---

    Code
      confirm_some_files(d)
    Condition
      Error:
      ! `d` does not identify at least one Drive file.

---

    Code
      confirm_single_file(d)
    Condition
      Error:
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

# as_dribble() reports missing or mistyped columns of a data frame

    Code
      as_dribble(data.frame(x = 1))
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. These required columns are missing:
      * `name`
      * `id`
      * `drive_resource`

---

    Code
      as_dribble(d)
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. This column has the wrong type:
      * `id` must be a character vector, not the number 1.

---

    Code
      as_dribble(d)
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. These columns have the wrong type:
      * `name` must be a character vector, not a <factor> object.
      * `drive_resource` must be a list, not the string "c".

# as_dribble.list() catches bad input

    Code
      as_dribble(list(drib_lst))
    Condition
      Error in `as_dribble()`:
      ! Can't make a <dribble> from this list.
      x Element 1 is missing 'id' and 'kind'.

---

    Code
      as_dribble(list(drib_lst))
    Condition
      Error in `validate_dribble()`:
      ! Invalid <dribble>. Can't confirm `kind = "drive#file"` or `kind = "drive#drive"` for all elements of the `drive_resource` column.

---

    Code
      as_dribble(list(ok_lst, list(name = "a"), list(id = "b"), list()))
    Condition
      Error in `as_dribble()`:
      ! Can't make a <dribble> from this list.
      x Element 2 is missing 'id' and 'kind'.
      x 2 other elements also have missing components.

# as_parent() throws specific errors

    Code
      foo <- d[0, ]
      as_parent(foo)
    Condition
      Error:
      ! Parent specified via `foo` is invalid:
      x Does not exist.

---

    Code
      foo <- d
      as_parent(foo)
    Condition
      Error:
      ! Parent specified via `foo` is invalid:
      x Doesn't uniquely identify exactly one folder or shared drive.

---

    Code
      foo <- d[1, ]
      as_parent(foo)
    Condition
      Error:
      ! Parent specified via `foo` is invalid:
      x Is neither a folder nor a shared drive.

