# Suspend authorization

Put googledrive into a de-authorized state. Instead of sending a token,
googledrive will send an API key. This can be used to access public
resources for which no Google sign-in is required. This is handy for
using googledrive in a non-interactive setting to make requests that do
not require a token. It will prevent the attempt to obtain a token
interactively in the browser. The user can configure their own API key
via
[`drive_auth_configure()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md)
and retrieve that key via
[`drive_api_key()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md).
In the absence of a user-configured key, a built-in default key is used.

## Usage

``` r
drive_deauth()
```

## See also

Other auth functions:
[`drive_auth()`](https://googledrive.tidyverse.org/dev/reference/drive_auth.md),
[`drive_auth_configure()`](https://googledrive.tidyverse.org/dev/reference/drive_auth_configure.md),
[`drive_scopes()`](https://googledrive.tidyverse.org/dev/reference/drive_scopes.md)

## Examples

``` r
if (FALSE) { # rlang::is_interactive()
drive_deauth()
drive_user()

# in a deauth'ed state, we can still get metadata on a world-readable file
public_file <- drive_example_remote("chicken.csv")
public_file
# we can still download it too
drive_download(public_file)
}
```
