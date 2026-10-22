# drive_example_remote() errors when >1 match

    Code
      drive_example_remote("chicken")
    Condition
      Error in `drive_example_remote()`:
      ! Found multiple matching remote files:
      * 'chicken_doc'
      * 'chicken_sheet'
      * 'chicken.csv'
      * 'chicken.jpg'
      * 'chicken.pdf'
      * 'chicken.txt'
      i Make the `matches` regular expression more specific.

# drive_example_local() errors when >1 match

    Code
      drive_example_local("chicken")
    Condition
      Error in `drive_example_local()`:
      ! Found multiple matching local files:
      * 'chicken.csv'
      * 'chicken.jpg'
      * 'chicken.pdf'
      * 'chicken.txt'
      i Make the `matches` regular expression more specific.

# drive_examples_local() errors when no match

    Code
      drive_examples_local("platypus")
    Condition
      Error in `drive_examples_local()`:
      ! Can't find a local example file with a name that matches "platypus".

# drive_example_local() checks `matches`

    Code
      drive_example_local(letters)
    Condition
      Error in `drive_example_local()`:
      ! `matches` must be a single string, not a character vector.

---

    Code
      drive_example_local(as_id("abc"))
    Condition
      Error in `drive_example_local()`:
      ! `matches` must be a regular expression, not a Drive ID.

