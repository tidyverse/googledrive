# Access shared drives

A shared drive supports files owned by an organization rather than an
individual user. Shared drives follow different sharing and ownership
models from a specific user's "My Drive". Shared drives are the
successors to the earlier concept of Team Drives.

How to capture a shared drive or files/folders that live on a shared
drive for downstream use:

- [`shared_drive_find()`](https://googledrive.tidyverse.org/dev/reference/shared_drive_find.md)
  and
  [`shared_drive_get()`](https://googledrive.tidyverse.org/dev/reference/shared_drive_get.md)
  return a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
  with metadata on shared drives themselves. You will need this in order
  to use a shared drive in certain file operations. For example, you can
  specify a shared drive as the parent folder via the `path` argument
  for upload, move, copy, etc. In that context, the id of a shared drive
  functions like the id of its top-level or root folder.

- [`drive_find()`](https://googledrive.tidyverse.org/dev/reference/drive_find.md)
  and
  [`drive_get()`](https://googledrive.tidyverse.org/dev/reference/drive_get.md)
  return a
  [`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
  with metadata on files, including folders. Both can be directed to
  search for files on shared drives using the optional arguments
  `shared_drive` or `corpus` (documented below).

Regard the functions mentioned above as the official "port of entry" for
working with shared drives. Use these functions to capture your
target(s) in a
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
to pass along to other googledrive functions. The flexibility to refer
to files by name or path does not apply as broadly to shared drives.
While it's always a good idea to get things into a
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
early, for shared drives it's often required.

## Specific shared drive

To search one specific shared drive, pass its name, marked id, or
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md)
to `shared_drive` somewhere in the call, like so:

    drive_find(..., shared_drive = "i_am_a_shared_drive_name")
    drive_find(..., shared_drive = as_id("i_am_a_shared_drive_id"))
    drive_find(..., shared_drive = i_am_a_shared_drive_dribble)

The value provided to `shared_drive` is pre-processed with
[`as_shared_drive()`](https://googledrive.tidyverse.org/dev/reference/as_shared_drive.md).

## Other collections

To search other collections, pass the `corpus` parameter somewhere in
the call, like so:

    drive_find(..., corpus = "user")
    drive_find(..., corpus = "allDrives")
    drive_find(..., corpus = "domain")

Possible values of `corpus` and what they mean:

- `"user"`: Queries files that the user has accessed, including both
  shared drive and My Drive files.

- `"drive"`: Queries all items in the shared drive specified via
  `shared_drive`. googledrive automatically fills this in whenever
  `shared_drive` is not `NULL`.

- `"allDrives"`: Queries files that the user has accessed and all shared
  drives in which they are a member. Note that the response may include
  `incompleteSearch : true`, indicating that some corpora were not
  searched for this request (currently, googledrive does not surface
  this). Prefer `"user"` or `"drive"` to `"allDrives"` for efficiency.

- `"domain"`: Queries files that are shared to the domain, including
  both shared drive and My Drive files.

## Google blogs and docs

Here is some of the best official Google reading about shared drives:

- [Team Drives is being renamed to shared
  drives](https://workspaceupdates.googleblog.com/2019/04/shared-drives.html)
  from Google Workspace blog

- [Upcoming changes to the Google Drive API and Google Picker
  API](https://cloud.google.com/blog/products/application-development/upcoming-changes-to-the-google-drive-api-and-google-picker-api)
  from the Google Cloud blog

- <https://developers.google.com/drive/api/v3/about-shareddrives>

- <https://developers.google.com/drive/api/v3/shared-drives-diffs>

- Get started with shared drives:
  `https://support.google.com/a/users/answer/9310351` from Google
  Workspace Learning Center

- Best practices for shared drives:
  `https://support.google.com/a/users/answer/9310156` from Google
  Workspace Learning Center

## API docs

googledrive implements shared drive support as outlined here:

- <https://developers.google.com/drive/api/v3/enable-shareddrives>

Users shouldn't need to know any of this, but here are details for the
curious. The extra information needed to search shared drives consists
of the following query parameters:

- `corpora`: Where to search? Formed from googledrive's `corpus`
  argument.

- `driveId`: The id of a specific shared drive. Only allowed – and also
  absolutely required – when `corpora = "drive"`. When user specifies a
  `shared_drive`, googledrive sends its id and also infers that
  `corpora` should be set to `"drive"`.

- `includeItemsFromAllDrives`: Do you want to see shared drive items?
  Obviously, this should be `TRUE` and googledrive sends this whenever
  shared drive parameters are detected.

- `supportsAllDrives`: Does the sending application (googledrive, in
  this case) know about shared drive? Obviously, this should be `TRUE`
  and googledrive sends it for all applicable endpoints, all the time.
