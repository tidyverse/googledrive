# given the files owned by the googledrive-file-keeper service account,
# create/update an inventory file consulted by drive_examples_remote()

library(here)
library(glue)
library(googledrive)
library(tidyverse)

# auth with the special-purpose service account
filename <- glue("~/.R/gargle/googledrive-file-keeper.json")
drive_auth(path = filename)
# user should be googledrive-file-keeper
drive_user()

# exclude the inventory file ... too meta!
dat <- drive_find(q = "not name contains 'drive_examples_remote'")

if (anyDuplicated(dat$name)) {
  stop("Duplicated file names! You are making a huge mistake.")
}

dat <- dat %>%
  drive_reveal("mime_type") %>%
  select(name, mime_type, id) %>%
  arrange(name, mime_type)

# record in local csv, because the visibility afforded by a plain old csv file
# is useful to me, e.g. easy to see change over time
write_csv(
  dat,
  file = here("inst", "extdata", "data", "remote_example_files.csv")
)

# keep just (name, id) for the official lookup Sheet
dat2 <- dat %>%
  select(name, id)
dat2

# PUT into official inventory csv
x <- tempfile(fileext = ".csv")
write_csv(dat2, file = x)

y <- drive_put(x, "drive_examples_remote.csv")
drive_share_anyone(y)
# drive_browse(y)
as_id(y)
# "1XiwJJdoqoZ876OoSTjsnBZ5SxxUg6gUC"
