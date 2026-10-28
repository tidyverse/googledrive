# Write/read a googledrive user token

**\[experimental\]**

This pair of functions writes an OAuth2 user token to file and reads it
back in. This is rarely necessary when working in your primary,
interactive computing environment. In that setting, it is recommended to
lean into the automatic token caching built-in to googledrive / gargle.
However, when preparing a user token for use elsewhere, such as in CI or
in a deployed data product, it can be useful to take the full control
granted by `drive_token_write()` and `drive_token_read()`.

Below is an outline of the intended workflow, but you will need to fill
in particulars, such as filepaths and environment variables:

- Do auth in your primary, interactive environment as the target user,
  with the desired OAuth client and scopes.

      drive_auth("jane@example.com", cache = FALSE)

- Confirm you are logged in as the intended user:

      drive_user()

- Write the current token to file:

      drive_token_write(
        path = "path/to/googledrive-token.rds",
        key = "GOOGLEDRIVE_TOKEN_KEY"
      )

- In the deployed, non-interactive setting, read the token from file and
  tell googledrive to use it:

      drive_auth(token = drive_token_read(
        path = "path/to/googledrive-token.rds",
        key = "GOOGLEDRIVE_TOKEN_KEY"
      ))

## Usage

``` r
drive_token_write(
  token = drive_token(),
  path = "googledrive-token.rds",
  key = NULL
)

drive_token_read(path = "googledrive-token.rds", key = NULL)
```

## Arguments

- token:

  A token with class
  [Token2.0](https://httr.r-lib.org/reference/Token-class.html) or an
  object of httr's class `request`, i.e. a token that has been prepared
  with [`httr::config()`](https://httr.r-lib.org/reference/config.html)
  and has a
  [Token2.0](https://httr.r-lib.org/reference/Token-class.html) in the
  `auth_token` component.

- path:

  The path to write to (`drive_token_write()`) or to read from
  (`drive_token_read()`).

- key:

  Encryption key, as implemented by httr2's [secret
  functions](https://httr2.r-lib.org/reference/secrets.html). If absent,
  a built-in `key` is used. If supplied, the `key` should usually be the
  name of an environment variable whose value was generated with
  [`gargle::secret_make_key()`](https://gargle.r-lib.org/reference/gargle_secret.html)
  (which is a copy of
  [`httr2::secret_make_key()`](https://httr2.r-lib.org/reference/secrets.html)).
  The `key` argument of `drive_token_read()` must match the `key` used
  in `drive_token_write()`.

## Security

`drive_token_write()` and `drive_token_read()` have a more
security-oriented implementation than the default token caching
strategy. OAuth2 user tokens are somewhat opaque by definition, because
they aren't written to file in a particularly transparent format.
However, `drive_token_write()` always applies some additional
obfuscation to make such credentials even more resilient against
scraping by an automated tool. However, a knowledgeable R programmer
could decode the credential with some effort. The default behaviour of
`drive_token_write()` (called without `key`) is suitable for tokens
stored in a relatively secure place, such as on Posit Connect within
your organization.

To prepare a stored credential for exposure in a more public setting,
such as on GitHub or CRAN, you must actually encrypt it, using a `key`
known only to you. You must make the encryption `key` available via a
secure environment variable in any setting where you wish to decrypt and
use the token, such as on GitHub Actions.
