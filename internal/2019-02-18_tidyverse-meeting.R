## live demo from group meeting re: gargle stuff
load_all(".")

## present myself as "RStudio Jenny"
drive_find(n_max = 10)
drive_find(type = "spreadsheet")

## what token am I sending?
drive_token()
.auth$cred

## explicitly declare this: "I want to send unauthorized requests"
drive_deauth()

## what token do I send now? NONE!
drive_token()

## access a world-readable document = gapminder Sheet
(gapminder <- googlesheets::gs_gap_url())

(ss <- drive_get(as_id(gapminder)))

drive_download(ss, "gapminder.csv", overwrite = TRUE)
readLines("gapminder.csv", n = 6)

## now I want to be "Gmail Jenny"
drive_auth(email = "jenny.f.bryan@gmail.com")

## notice I see different documents from "Rstudio Jenny"
drive_find(n_max = 10)
drive_find(type = "spreadsheet")

library(googlesheets4)

## let's switch back to RStudio Jenny via a token choose
drive_auth(email = NA)

## Find the 'Families' spreadsheet Hadley let us make
families_ss <- drive_find("Families", type = "spreadsheet")

families <- sheets_read(families_ss, n_max = 13)
families
View(families)

## go back to slides here

## inspect internally stored endpoints

## googledrive
View(.endpoints)

## googlesheets4
View(googlesheets4:::.endpoints)
