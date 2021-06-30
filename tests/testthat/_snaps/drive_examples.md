# drive_example_remote() errors when >1 match

    Code
      drive_example_remote("chicken")
    Error <rlang_error>
      Found multiple matching remote files:
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
    Error <rlang_error>
      Found multiple matching local files:
      * 'chicken.csv'
      * 'chicken.jpg'
      * 'chicken.pdf'
      * 'chicken.txt'
      i Make the `matches` regular expression more specific.

# drive_examples_local() errors when no match

    Code
      drive_examples_local("platypus")
    Error <rlang_error>
      Can't find a local example file with a name that matches "platypus".

