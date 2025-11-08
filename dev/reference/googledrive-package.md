# googledrive: An Interface to Google Drive

googledrive allows you to interact with files on Google Drive from R.

`googledrive::drive_find(n_max = 50)` lists up to 50 of the files you
see in [My Drive](https://drive.google.com). You can expect to be sent
to your browser here, to authenticate yourself and authorize the
googledrive package to deal on your behalf with Google Drive.

Most functions begin with the prefix `drive_`.

The goal is to allow Drive access that feels similar to Unix file system
utilities, e.g., `find`, `ls`, `mv`, `cp`, `mkdir`, and `rm`.

The metadata for one or more Drive files is held in a
[`dribble`](https://googledrive.tidyverse.org/dev/reference/dribble.md),
a "Drive tibble". This is a data frame with one row per file. A dribble
is returned (and accepted) by almost every function in googledrive. It
is designed to give people what they want (file name), track what the
API wants (file id), and to hold the metadata needed for general file
operations.

googledrive is "pipe-friendly" (either the base `|>` or magrittr `%>%`
pipe), but does not require its use.

Please see the googledrive website for full documentation:

- <https://googledrive.tidyverse.org/index.html>

In addition to function-specific help, there are several articles which
are indexed here:

- [Article index](https://googledrive.tidyverse.org/articles/index.html)

## See also

Useful links:

- <https://googledrive.tidyverse.org>

- <https://github.com/tidyverse/googledrive>

- Report bugs at <https://github.com/tidyverse/googledrive/issues>

## Author

**Maintainer**: Jennifer Bryan <jenny@posit.co>
([ORCID](https://orcid.org/0000-0002-6983-2759))

Authors:

- Lucy D'Agostino McGowan

Other contributors:

- Posit Software, PBC \[copyright holder, funder\]
