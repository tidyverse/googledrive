# partition_path() fails for bad input

    Code
      partition_path(letters)
    Error <simpleError>
      is_string(path) is not TRUE

---

    Code
      partition_path(dribble())
    Error <simpleError>
      is_string(path) is not TRUE

---

    Code
      partition_path(as_id("123"))
    Error <simpleError>
      is_string(path) is not TRUE

# rationalize_path_name() errors for bad `name`, before hitting API

    Code
      rationalize_path_name(name = letters)
    Error <simpleError>
      is_string(name) is not TRUE

