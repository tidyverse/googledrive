# new_dribble() requires data.frame and adds the dribble class

    Code
      new_dribble(1:3)
    Error <simpleError>
      inherits(x, "data.frame") is not TRUE

# validate_dribble() checks class, var names, var types

    Code
      validate_dribble("a")
    Error <simpleError>
      inherits(x, "dribble") is not TRUE

---

    Code
      validate_dribble(d)
    Error <simpleError>
      Invalid dribble. These columns have the wrong type:
      id

---

    Code
      validate_dribble(d)
    Error <simpleError>
      Invalid dribble. These required column names are missing:
      name

---

    Code
      validate_dribble(d)
    Error <simpleError>
      Invalid dribble. Can't confirm `kind = "drive#file"` or `kind = "drive#drive"` for all elements of the nominal `drive_resource` column

# dribble nrow checkers work

    Code
      confirm_single_file(dribble())
    Error <simpleError>
      'dribble()' does not identify at least one Drive file.

---

    Code
      confirm_some_files(dribble())
    Error <simpleError>
      'dribble()' does not identify at least one Drive file.

---

    Code
      confirm_single_file(d)
    Error <simpleError>
      'd' identifies more than one Drive file.

# as_dribble() default method handles unsuitable input

    Code
      as_dribble(1.3)
    Error <simpleError>
      Don't know how to coerce object of class <numeric> into a dribble

---

    Code
      as_dribble(TRUE)
    Error <simpleError>
      Don't know how to coerce object of class <logical> into a dribble

# as_dribble.list() catches bad input

    Code
      as_dribble(list(drib_lst))
    Error <simpleError>
      purrr::map_lgl(x, ~all(required_nms %in% names(.x))) is not TRUE

---

    Code
      as_dribble(list(drib_lst))
    Error <simpleError>
      Invalid dribble. Can't confirm `kind = "drive#file"` or `kind = "drive#drive"` for all elements of the nominal `drive_resource` column

