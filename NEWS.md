# googledrive (development version)

* `as_id()` (and hence `drive_download()`) work for Google Colab links (#459, @MichaelChirico).

# googledrive 2.1.1

* `drive_auth(subject =)` is a new argument that can be used with
  `drive_auth(path =)`, i.e. when using a service account. The `path` and
  `subject` arguments are ultimately processed by
  `gargle::credentials_service_account()` and support the use of a service
  account to impersonate a normal user (#413).

* All requests now route through `gargle::request_retry()` (#380).

* `drive_scopes()` is a new function to access scopes relevant to the Drive API.
  When called without arguments, `drive_scopes()` returns a named vector of
  scopes, where the names are the associated short aliases. `drive_scopes()` can
  also be called with a character vector; any element that's recognized as a
  short alias is replaced with the associated full scope (#430).
  
* Various internal changes to sync up with gargle v1.5.0.

# googledrive 2.1.0

## Syncing up with gargle

Version 1.3.0 of gargle introduced some changes around OAuth and googledrive is syncing up that:

* `drive_oauth_client()` is a new function to replace the now-deprecated `drive_oauth_app()`.
* The new `client` argument of `drive_auth_configure()` replaces the now-deprecated `app` argument.
* The documentation of `drive_auth_configure()` emphasizes that the preferred way to "bring your own OAuth client" is by providing the JSON downloaded from Google Developers Console.

## Shared drives

`drive_ls(recursive = TRUE)` now works when the target folder is on a shared drive (#265, @Falnesio).

`drive_mv()` no longer errors with "A shared drive item must have exactly one parent." when moving a file on a shared drive (#377).

## Other

`drive_auth()` now warns if the user specifies both `email` and `path`, because this is almost always an error (#420).

`drive_auth_config()` was deprecated in googledrive 1.0.0 (released 2019-08-19) and is now defunct.

`drive_example()` was deprecated in googledrive 2.0.0 (released 2021-07-08) and is now defunct.

# googledrive 2.0.0

## Team Drives are dead! Long live shared drives!

Google Drive has rebranded Team Drives as **shared drives**.
While anyone can have a **My Drive**, shared drives are only available for Google Workspace (previously known as G Suite).
Shared drives and the files within are owned by a team/organization, as opposed to an individual.

In googledrive, all `team_drive_*()` functions have been deprecated, in favor of
their `shared_drive_*()` successors.
Likewise, any `team_drive` argument has been deprecated, in favor of a new `shared_drive` argument.
The terms used to describe which collections to search have also changed slightly, with `"allDrives"` replacing `"all"`.
This applies to the `corpus` argument of `drive_find()` and `drive_get()`.

Where to learn more:

* [Team Drives is being renamed to shared drives](https://workspaceupdates.googleblog.com/2019/04/shared-drives.html) from Google Workspace blog
* [Upcoming changes to the Google Drive API and Google Picker API](https://cloud.google.com/blog/products/application-development/upcoming-changes-to-the-google-drive-api-and-google-picker-api) from the Google Cloud blog

## Single parenting and shortcuts

As of 2020-09-30, Drive no longer allows a file to be placed in multiple folders; going forward, every file will have exactly 1 parent folder.
In many cases that parent is just the top-level or root folder of your "My Drive" or of a shared drive.

This change has been accompanied by the introduction of file **shortcuts**, which function much like symbolic or "soft" links.
Shortcuts are the new way to make a file appear to be in more than one place or, said another way, the new way for one Drive file to be associated with more than one Drive filepath.
A shortcut is a special type of Drive file, characterized by the `application/vnd.google-apps.shortcut` MIME type.
You can make a shortcut to any Drive file, including to a Drive folder.

Drive has been migrating existing files to the one-parent state, i.e., "single parenting" them.
Drive selects the most suitable parent folder to keep, "based on the hierarchy's properties", and replaces any other parent-child relationships with a shortcut.

New functions related to shortcuts:

* `shortcut_create()`: creates a shortcut to a specific Drive file (or folder).
* `shortcut_resolve()`: resolves a shortcut to its target, i.e. the file it
  refers to. Works for multiple files at once, i.e. the input can be a mix of
  shortcuts and non-shortcuts. The non-shortcuts are passed through and the
  shortcuts are replaced by their targets.
  
How interacts with googledrive's support for specifying file by filepath:

* Main principle: shortcuts are first-class Drive files that we assume users
  will need to manipulate with googledrive. In general, there is no automatic
  resolution to the target file.
* `drive_reveal(what = "path")` returns the canonical path, i.e. there will be
  no shortcuts among the non-terminal "folder" parts of the returned path.
* `drive_get(path = "foo/")` can retrieve a folder named "foo" or a shortcut
  named "foo", whose target is a folder.
* When a shortcut-to-a-folder is specified as the `path`, in a context where it
  unambiguously specifies a parent folder, the `path` **is** auto-resolved to
  its target folder. This is the exception to the "no automatic resolution"
  rule. Functions affected:
  - `drive_ls(path, ...)`
  - `drive_create(name, path, ...)` and its convenience wrappers `drive_mkdir()`
    and `shortcut_create()`
  - `drive_cp(file, path, ...)`
  - `drive_mv(file, path, ...)`
  - `drive_upload(media, path, ...)` and its close friend `drive_put()`

Further reading about changes to the Drive folder model:

* [Simplifying Google Drive’s folder structure and sharing models](https://workspace.google.com/blog/product-announcements/simplifying-google-drives-folder-structure-and-sharing-models)
* [Single-parenting behavior changes](https://developers.google.com/drive/api/v3/ref-single-parent)
* [Create a shortcut to a Drive file](https://developers.google.com/drive/api/v3/shortcuts)
* Find files & folders with Google Drive shortcuts: `https://support.google.com/drive/answer/9700156`

## User interface

The user interface has gotten more stylish, thanks to the cli package (<https://cli.r-lib.org>).
All informational messages, warnings, and errors are now emitted via cli, which uses rlang's condition functions under-the-hood.

`googledrive_quiet` is a new option to suppress informational messages from googledrive.
Unless it's explicitly set to `TRUE`, the default is to message.

The `verbose` argument of all `drive_*()` functions is deprecated and will be removed in a future release.
In the current release, `verbose = FALSE` is still honored, but generates a warning.

`local_drive_quiet()` and `with_drive_quiet()` are [withr-style](https://withr.r-lib.org) convenience helpers for setting `googledrive_quiet = TRUE` for some limited scope.

## Other changes

* We now share a variety of world-readable, persistent example files on Drive,
  for use in examples and documentation. These remote example files complement
  the local example files that were already included in googledrive.
  
  `drive_example()` is deprecated in favor of these accessors for example files:
  - Plural forms:`drive_examples_remote()`, `drive_examples_local()`
  - Singular forms: `drive_example_remote()`, `drive_example_local()`

* `drive_read_string()` and `drive_read_raw()` are new functions that read the
  content of a Drive file directly into R, skipping the step of downloading to a
  local file (#81).

* `drive_reveal(what = "property_name")` now works for any property found in
  the file metadata stored in the `drive_resource` column. The new column is
  also simplified in more cases now, e.g. to `character` or `logical`. If the
  `property_name` suggests it's a date-time, we return `POSIXct`.

* We've modernized the mechanisms by which the `dribble` class is (or is not)
  retained by various data frame operations.
  This boils down to updating or adding methods used by the base, dplyr,
  pillar/tibble, and vctrs packages.
  
  We focus on compatibility with dplyr >= 1.0.0, which was released a year ago.
  googledrive only Suggests dplyr, so all this really means is that `dribble`
  manipulation via dplyr now works best with dplyr >= 1.0.0.

* The `drive_id` S3 class is now implemented more fully, using the vctrs
  package (#93, #364):

  - The `drive_id` class will persist after mundane operations, like subsetting.
  - You can no longer put strings that are obviously invalid into a `drive_id`
    object.
  - The `id` column of a `dribble` is now an instance of `drive_id`.

## Dependency changes

cli, lifecycle, and withr are new in Imports.

pillar and vctrs are new in Imports, but were already indirect hard dependencies via tibble.

mockr is new in Suggests.

curl moves from Imports to Suggests, but remains an indirect hard dependency.

# googledrive 1.0.1

Patch release to modify a test for compatibility with an upcoming release of gargle.

`drive_share()` gains awareness of the `"fileOrganizer"` role (#302).

Better handling of filenames that include characters that have special meaning in a regular expression (#292).

`drive_find()` explicitly checks for and eliminates duplicate records for a file ID, guarding against repetition in the paginated results returned by the API. It would seem that this should never happen, but there is some indication that it does. (#272, #277, #279, #281)

`drive_share_anyone()` is a new convenience wrapper that makes a file readable by "anyone with a link".

`as_tibble()` method for `dribble` objects now passes `...` through, which could apply, for example, to tibble's `.name_repair` argument.

# googledrive 1.0.0

The release of version 1.0.0 marks two events:

  * The overall design of googledrive has survived ~2 years on CRAN, with very little need for change. The API and feature set is fairly stable.
  * There are changes in the auth interface that are not backwards compatible.
  
There is also new functionality that makes it less likely you'll create multiple files with the same name, without actually meaning to.

## Auth from gargle

googledrive's auth functionality now comes from the [gargle package](https://gargle.r-lib.org), which provides R infrastructure to work with Google APIs, in general. The same transition is happening in several other packages, such as [bigrquery](https://bigrquery.r-dbi.org) and [gmailr](https://gmailr.r-lib.org). This makes user interfaces more consistent and makes two new token flows available in googledrive:

  * Application Default Credentials
  * Service account tokens from the metadata server available to VMs running on GCE
  
Where to learn more:
  
  * Help for [`drive_auth()`](https://googledrive.tidyverse.org/reference/drive_auth.html) *all that most users need*
  * *details for more advanced users*
    - [Bring your own OAuth app or API key](https://googledrive.tidyverse.org/articles/articles/bring-your-own-app.html)
    - [How to get your own API credentials](https://gargle.r-lib.org/articles/get-api-credentials.html) 
    - [Non-interactive auth](https://gargle.r-lib.org/articles/non-interactive-auth.html)
    - [Auth when using R in the browser](https://gargle.r-lib.org/articles/auth-from-web.html)
    - [How gargle gets tokens](https://gargle.r-lib.org/articles/how-gargle-gets-tokens.html)
    - [Managing tokens securely](https://gargle.r-lib.org/articles/articles/managing-tokens-securely.html)

### Changes that a user will notice

OAuth2 tokens are now cached at the user level, by default, instead of in `.httr-oauth` in the current project. We recommend that you delete any vestigial `.httr-oauth` files lying around your googledrive projects and re-authorize googledrive, i.e. get a new token, stored in the new way.

googledrive uses a new OAuth "app", owned by a verified Google Cloud Project entitled "Tidyverse API Packages", which is the project name you will see on the OAuth consent screen. See our new [Privacy Policy](https://www.tidyverse.org/google_privacy_policy/) for details.

The local OAuth2 token key-value store now incorporates the associated Google user when indexing, which makes it easier to switch between Google identities.

The arguments and usage of `drive_auth()` have changed.

  * Previous signature (v0.1.3 and earlier)
  
    ``` r  
    drive_auth(
      oauth_token = NULL,                       # use `token` now
      service_token = NULL,                     # use `path` now
      reset = FALSE,                            
      cache = getOption("httr_oauth_cache"),
      use_oob = getOption("httr_oob_default"),
      verbose = TRUE
    )
    ```
  
  * Current signature (>= v1.0.0)
  
    ``` r
    drive_auth(
      email = gargle::gargle_oauth_email(),             # NEW!
      path = NULL,                                      # was `service_token`
      scopes = "https://www.googleapis.com/auth/drive", # NEW!
      cache = gargle::gargle_oauth_cache(),
      use_oob = gargle::gargle_oob_default(),
      token = NULL                                      # was `oauth_token`
    )
    ```

For full details see the resources listed in *Where to learn more* above. The change that probably affects the most code is the way to provide a service account token:
  - Previously: `drive_auth(service_token = "/path/to/your/service-account-token.json")` (v0.1.3 and earlier)
  - Now: `drive_auth(path = "/path/to/your/service-account-token.json")` (>= v1.0.0)

Auth configuration has also changed:

  * `drive_auth_configure()` is a variant of the now-deprecated `drive_auth_config()` whose explicit and only job is to *set* aspects of the configuration, i.e. the OAuth app or API key.
    - Use `drive_oauth_app()` (new) and `drive_api_key()` to *retrieve* a user-configured app or API key, if such exist.
    - These functions no longer return built-in auth assets, although built-in assets still exist and are used in the absence of user configuration.
  * `drive_deauth()` is how you go into a de-authorized state, i.e. send an API key in lieu of a token.
  
`drive_has_token()` is a new helper that simply reports whether a token is in place, without triggering the auth flow.

There are other small changes to the low-level developer-facing API:

  - `generate_request()` has been renamed to `request_generate()`.
  - `make_request()` had been renamed to `request_make()` and is a very thin wrapper around `gargle::request_make()` that only adds googledrive's user agent.
  - `build_request()` has been removed. If you can't do what you need with `request_generate()`, use `gargle::request_develop()` or `gargle::request_build()` directly.
  - `process_response()` has been removed. Instead, use `gargle::response_process(response)`, as we do inside googledrive.
  
## `overwrite = NA / TRUE / FALSE` and `drive_put()`

Google Drive doesn't impose a 1-to-1 relationship between files and filepaths, the way your local file system does. Therefore, when working via the Drive API (instead of in the browser), it's fairly easy to create multiple Drive files with the same name or filepath, without actually meaning to. This is perfectly valid on Drive, which identifies file by ID, but can be confusing and undesirable for humans.

googledrive v1.0.0 offers some new ways to fight this:

  * All functions that create a new item or rename/move an existing item have
    gained an `overwrite` argument.
  * `drive_put()` is a new convenience wrapper that figures out whether to call
    `drive_upload()` or `drive_update()`.
    
Changes inspired by #230.

### `overwrite = NA / TRUE / FALSE`

These functions gain an `overwrite` argument:

  * `drive_create()` *this whole function is new*
  * `drive_cp()`
  * `drive_mkdir()`
  * `drive_mv()`
  * `drive_rename()`
  * `drive_upload()`
  
The default of `overwrite = NA` corresponds to the current behaviour, which is to "Just. Do. It.", i.e. to not consider pre-existing files at all.

`overwrite = TRUE` requests to move a pre-existing file at the target filepath to the trash, prior to creating the new item. If 2 or more files are found, an error is thrown, because it's not clear which one(s) to trash.

`overwrite = FALSE` means the new item will only be created if there is no pre-existing file at that filepath.

Existence checks based on filepath (or name) can be expensive. This is why the default is `overwrite = NA`, in addition to backwards compatibility.

### `drive_put()`

Sometimes you have a file you will repeatedly send to Drive, i.e. the first time you run an analysis, you create the file and, when you re-run it, you update the file. Previously this was hard to express with googledrive.

`drive_put()` is useful here and refers to the HTTP verb `PUT`: create the thing if it doesn't exist or, if it does, replace its contents. A good explanation of `PUT` is [RESTful API Design -- PUT vs PATCH](https://medium.com/backticks-tildes/restful-api-design-put-vs-patch-4a061aa3ed0b).

In pseudo-code, here's the basic idea of `drive_put()`:

``` r
target_filepath <- <determined from arguments `path`, `name`, and `media`>
hits <- <get all Drive files at target_filepath>
if (no hits) {
 drive_upload(media, path, name, type, ..., verbose)
} else if (exactly 1 hit) {
 drive_update(hit, media, ..., verbose)
} else {
 ERROR
}
```

## Other changes

All functions that support `...` as a way to pass more parameters to the Drive API now have "tidy dots semantics": `!!!` is supported for splicing and `!!` can be used on the LHS of `:=`. Full docs are in [dynamic dots](https://rlang.r-lib.org/reference/dyn-dots.html).

`drive_find()` now sorts by "recency", by default.

`drive_create()` is a new function that creates a new empty file, with an optional file type specification (#258, @ianmcook). `drive_mkdir()` becomes a thin wrapper around `drive_create()`, with the file type hard-wired to "folder".

In `drive_mkdir()`, the optional parent directory is now known as `path` instead of `parent`. This is more consistent with everything else in googledrive, which became very obvious when adding `drive_create()` and the general `overwrite` functionality.

`drive_empty_trash()` now exploits the correct endpoint (as opposed to deleting individual files) and is therefore much faster (#203).

Colaboratory notebooks now have some MIME type support, in terms of the `type` argument in various functions (<https://colab.research.google.com/>). The internal table of known MIME types includes `"application/vnd.google.colab"`, which is associated with the file extension `.ipynb` and the human-oriented nickname `"colab"` (#207).

`drive_endpoints()` gains a singular friend, `drive_endpoint()` which returns exactly one endpoint. These helpers index into the internal list of Drive API endpoints with `[` and `[[`, respectively.

## Dependency changes

R 3.1 is no longer explicitly supported or tested. Our general practice is to support the current release (3.6), devel, and the 4 previous versions of R (3.5, 3.4, 3.3, 3.2). See [Which versions of R do tidyverse packages support?](https://www.tidyverse.org/blog/2019/04/r-version-support/).

gargle and magrittr are newly Imported.

rprojroot has been removed from Suggests, because we can now use a version of testthat recent enough to offer `testthat::test_path()`.

# googledrive 0.1.3

Minor patch release for compatibility with the imminent release of purrr 0.3.0.

# googledrive 0.1.2

* Internal usage of `glue::collapse()` modified to call `glue::glue_collapse()` if glue v1.3.0 or later is installed and `glue::collapse()` otherwise. Eliminates a deprecation warning emanating from glue. (#222 @jimhester)

# googledrive 0.1.1

* initial CRAN release
