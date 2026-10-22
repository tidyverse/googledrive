# root_folder() and root_id() work

    Code
      root_folder()
    Output
      # A dribble: 1 x 3
        name     id                  drive_resource   
        <chr>    <drv_id>            <list>           
      1 My Drive 0AK935f1rlmIZUk9PVA <named list [34]>

---

    Code
      root_id()
    Output
      <drive_id[1]>
      [1] 0AK935f1rlmIZUk9PVA

# rootize_path() errors for leading slash

    Code
      rootize_path("/")
    Condition
      Error in `rootize_path()`:
      ! googledrive does not allow paths to start with `/`

# partition_path() fails for bad input

    Code
      partition_path(letters)
    Condition
      Error:
      ! `path` must be a single string, not a character vector.

---

    Code
      partition_path(dribble())
    Condition
      Error:
      ! `path` must be a single string, not a <dribble> object.

---

    Code
      partition_path(as_id("123"))
    Condition
      Error:
      ! `path` must be a Drive path, not a Drive ID.

# rationalize_path_name() errors for bad `name`, before hitting API

    Code
      rationalize_path_name(name = letters)
    Condition
      Error:
      ! `name` must be a single string, not a character vector.

---

    Code
      rationalize_path_name(name = as_id("abc"))
    Condition
      Error:
      ! `name` must be a file name, not a Drive ID.
      i Did you mean to pass the ID as `path`?

