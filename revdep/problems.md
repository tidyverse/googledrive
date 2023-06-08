# googlesheets4

<details>

* Version: 1.1.0
* GitHub: https://github.com/tidyverse/googlesheets4
* Source code: https://github.com/cran/googlesheets4
* Date/Publication: 2023-03-23 22:42:08 UTC
* Number of recursive dependencies: 82

Run `revdepcheck::cloud_details(, "googlesheets4")` for more info

</details>

## Newly broken

*   checking examples ... ERROR
    ```
    Running examples in ‘googlesheets4-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: gs4_auth_configure
    > ### Title: Edit and view auth configuration
    > ### Aliases: gs4_auth_configure gs4_api_key gs4_oauth_client
    > 
    > ### ** Examples
    > 
    > # see and store the current user-configured OAuth client (probably `NULL`)
    ...
    > # this example JSON is indicative, but fake
    > path_to_json <- system.file(
    +   "extdata", "data", "client_secret_123.googleusercontent.com.json",
    +   package = "googledrive"
    + )
    > gs4_auth_configure(path = path_to_json)
    Error: parse error: premature EOF
                                           
                         (right here) ------^
    Execution halted
    ```

