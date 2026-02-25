# Get info on Drive capabilities

Gets information about the user, the user's Drive, and system
capabilities. This function mostly exists to power
[`drive_user()`](https://googledrive.tidyverse.org/dev/reference/drive_user.md),
which extracts the most useful information (the information on current
user) and prints it nicely.

## Usage

``` r
drive_about()
```

## Value

A list representation of a Drive [about
resource](https://developers.google.com/drive/api/v3/reference/about)

## See also

Wraps the `about.get` endpoint:

- <https://developers.google.com/drive/api/v3/reference/about/get>

## Examples

``` r
drive_about()
#> $kind
#> [1] "drive#about"
#> 
#> $user
#> $user$kind
#> [1] "drive#user"
#> 
#> $user$displayName
#> [1] "googledrive-docs@gargle-169921.iam.gserviceaccount.com"
#> 
#> $user$photoLink
#> [1] "https://lh3.googleusercontent.com/a/ACg8ocIG4HCyGaPbQ53NSBY6jFcH8mA_4VFotnEVUPuC5yFoGqwE8Q=s64"
#> 
#> $user$me
#> [1] TRUE
#> 
#> $user$permissionId
#> [1] "09204227840243713330"
#> 
#> $user$emailAddress
#> [1] "googledrive-docs@gargle-169921.iam.gserviceaccount.com"
#> 
#> 
#> $storageQuota
#> $storageQuota$limit
#> [1] "16106127360"
#> 
#> $storageQuota$usage
#> [1] "2836690"
#> 
#> $storageQuota$usageInDrive
#> [1] "2836690"
#> 
#> $storageQuota$usageInDriveTrash
#> [1] "0"
#> 
#> 
#> $importFormats
#> $importFormats$`application/x-vnd.oasis.opendocument.presentation`
#> $importFormats$`application/x-vnd.oasis.opendocument.presentation`[[1]]
#> [1] "application/vnd.google-apps.presentation"
#> 
#> 
#> $importFormats$`text/tab-separated-values`
#> $importFormats$`text/tab-separated-values`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`image/gif`
#> $importFormats$`image/gif`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.ms-excel.sheet.macroenabled.12`
#> $importFormats$`application/vnd.ms-excel.sheet.macroenabled.12`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`application/vnd.openxmlformats-officedocument.wordprocessingml.template`
#> $importFormats$`application/vnd.openxmlformats-officedocument.wordprocessingml.template`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.ms-word.template.macroenabled.12`
#> $importFormats$`application/vnd.ms-word.template.macroenabled.12`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.openxmlformats-officedocument.wordprocessingml.document`
#> $importFormats$`application/vnd.openxmlformats-officedocument.wordprocessingml.document`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`video/ogg`
#> $importFormats$`video/ogg`[[1]]
#> [1] "application/vnd.google-apps.vid"
#> 
#> 
#> $importFormats$`application/vnd.ms-excel`
#> $importFormats$`application/vnd.ms-excel`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`text/rtf`
#> $importFormats$`text/rtf`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/x-vnd.oasis.opendocument.text`
#> $importFormats$`application/x-vnd.oasis.opendocument.text`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/msword`
#> $importFormats$`application/msword`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/pdf`
#> $importFormats$`application/pdf`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/x-msmetafile`
#> $importFormats$`application/x-msmetafile`[[1]]
#> [1] "application/vnd.google-apps.drawing"
#> 
#> 
#> $importFormats$`text/markdown`
#> $importFormats$`text/markdown`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`image/x-bmp`
#> $importFormats$`image/x-bmp`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/rtf`
#> $importFormats$`application/rtf`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`text/html`
#> $importFormats$`text/html`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.oasis.opendocument.text`
#> $importFormats$`application/vnd.oasis.opendocument.text`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.openxmlformats-officedocument.presentationml.presentation`
#> $importFormats$`application/vnd.openxmlformats-officedocument.presentationml.presentation`[[1]]
#> [1] "application/vnd.google-apps.presentation"
#> 
#> 
#> $importFormats$`text/csv`
#> $importFormats$`text/csv`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`application/vnd.oasis.opendocument.presentation`
#> $importFormats$`application/vnd.oasis.opendocument.presentation`[[1]]
#> [1] "application/vnd.google-apps.presentation"
#> 
#> 
#> $importFormats$`image/jpg`
#> $importFormats$`image/jpg`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`video/quicktime`
#> $importFormats$`video/quicktime`[[1]]
#> [1] "application/vnd.google-apps.vid"
#> 
#> 
#> $importFormats$`text/richtext`
#> $importFormats$`text/richtext`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`video/mp4`
#> $importFormats$`video/mp4`[[1]]
#> [1] "application/vnd.google-apps.vid"
#> 
#> 
#> $importFormats$`video/webm`
#> $importFormats$`video/webm`[[1]]
#> [1] "application/vnd.google-apps.vid"
#> 
#> 
#> $importFormats$`image/jpeg`
#> $importFormats$`image/jpeg`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`image/bmp`
#> $importFormats$`image/bmp`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`text/x-markdown`
#> $importFormats$`text/x-markdown`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.ms-powerpoint.presentation.macroenabled.12`
#> $importFormats$`application/vnd.ms-powerpoint.presentation.macroenabled.12`[[1]]
#> [1] "application/vnd.google-apps.presentation"
#> 
#> 
#> $importFormats$`text/comma-separated-values`
#> $importFormats$`text/comma-separated-values`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`image/pjpeg`
#> $importFormats$`image/pjpeg`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.google-apps.script+text/plain`
#> $importFormats$`application/vnd.google-apps.script+text/plain`[[1]]
#> [1] "application/vnd.google-apps.script"
#> 
#> 
#> $importFormats$`application/vnd.ms-word.document.macroenabled.12`
#> $importFormats$`application/vnd.ms-word.document.macroenabled.12`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.sun.xml.writer`
#> $importFormats$`application/vnd.sun.xml.writer`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.ms-powerpoint.slideshow.macroenabled.12`
#> $importFormats$`application/vnd.ms-powerpoint.slideshow.macroenabled.12`[[1]]
#> [1] "application/vnd.google-apps.presentation"
#> 
#> 
#> $importFormats$`text/plain`
#> $importFormats$`text/plain`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.oasis.opendocument.spreadsheet`
#> $importFormats$`application/vnd.oasis.opendocument.spreadsheet`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`application/x-vnd.oasis.opendocument.spreadsheet`
#> $importFormats$`application/x-vnd.oasis.opendocument.spreadsheet`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`image/png`
#> $importFormats$`image/png`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.openxmlformats-officedocument.spreadsheetml.template`
#> $importFormats$`application/vnd.openxmlformats-officedocument.spreadsheetml.template`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`application/vnd.ms-powerpoint`
#> $importFormats$`application/vnd.ms-powerpoint`[[1]]
#> [1] "application/vnd.google-apps.presentation"
#> 
#> 
#> $importFormats$`application/vnd.ms-excel.template.macroenabled.12`
#> $importFormats$`application/vnd.ms-excel.template.macroenabled.12`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`application/vnd.openxmlformats-officedocument.presentationml.template`
#> $importFormats$`application/vnd.openxmlformats-officedocument.presentationml.template`[[1]]
#> [1] "application/vnd.google-apps.presentation"
#> 
#> 
#> $importFormats$`image/x-png`
#> $importFormats$`image/x-png`[[1]]
#> [1] "application/vnd.google-apps.document"
#> 
#> 
#> $importFormats$`application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
#> $importFormats$`application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`[[1]]
#> [1] "application/vnd.google-apps.spreadsheet"
#> 
#> 
#> $importFormats$`application/vnd.google-apps.script+json`
#> $importFormats$`application/vnd.google-apps.script+json`[[1]]
#> [1] "application/vnd.google-apps.script"
#> 
#> 
#> $importFormats$`application/vnd.openxmlformats-officedocument.presentationml.slideshow`
#> $importFormats$`application/vnd.openxmlformats-officedocument.presentationml.slideshow`[[1]]
#> [1] "application/vnd.google-apps.presentation"
#> 
#> 
#> $importFormats$`application/vnd.ms-powerpoint.template.macroenabled.12`
#> $importFormats$`application/vnd.ms-powerpoint.template.macroenabled.12`[[1]]
#> [1] "application/vnd.google-apps.presentation"
#> 
#> 
#> 
#> $exportFormats
#> $exportFormats$`application/vnd.google-apps.document`
#> $exportFormats$`application/vnd.google-apps.document`[[1]]
#> [1] "application/rtf"
#> 
#> $exportFormats$`application/vnd.google-apps.document`[[2]]
#> [1] "application/vnd.oasis.opendocument.text"
#> 
#> $exportFormats$`application/vnd.google-apps.document`[[3]]
#> [1] "text/html"
#> 
#> $exportFormats$`application/vnd.google-apps.document`[[4]]
#> [1] "application/pdf"
#> 
#> $exportFormats$`application/vnd.google-apps.document`[[5]]
#> [1] "text/x-markdown"
#> 
#> $exportFormats$`application/vnd.google-apps.document`[[6]]
#> [1] "text/markdown"
#> 
#> $exportFormats$`application/vnd.google-apps.document`[[7]]
#> [1] "application/epub+zip"
#> 
#> $exportFormats$`application/vnd.google-apps.document`[[8]]
#> [1] "application/zip"
#> 
#> $exportFormats$`application/vnd.google-apps.document`[[9]]
#> [1] "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
#> 
#> $exportFormats$`application/vnd.google-apps.document`[[10]]
#> [1] "text/plain"
#> 
#> 
#> $exportFormats$`application/vnd.google-apps.vid`
#> $exportFormats$`application/vnd.google-apps.vid`[[1]]
#> [1] "video/mp4"
#> 
#> 
#> $exportFormats$`application/vnd.google-apps.spreadsheet`
#> $exportFormats$`application/vnd.google-apps.spreadsheet`[[1]]
#> [1] "application/x-vnd.oasis.opendocument.spreadsheet"
#> 
#> $exportFormats$`application/vnd.google-apps.spreadsheet`[[2]]
#> [1] "text/tab-separated-values"
#> 
#> $exportFormats$`application/vnd.google-apps.spreadsheet`[[3]]
#> [1] "application/pdf"
#> 
#> $exportFormats$`application/vnd.google-apps.spreadsheet`[[4]]
#> [1] "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
#> 
#> $exportFormats$`application/vnd.google-apps.spreadsheet`[[5]]
#> [1] "text/csv"
#> 
#> $exportFormats$`application/vnd.google-apps.spreadsheet`[[6]]
#> [1] "application/zip"
#> 
#> $exportFormats$`application/vnd.google-apps.spreadsheet`[[7]]
#> [1] "application/vnd.oasis.opendocument.spreadsheet"
#> 
#> 
#> $exportFormats$`application/vnd.google-apps.jam`
#> $exportFormats$`application/vnd.google-apps.jam`[[1]]
#> [1] "application/pdf"
#> 
#> 
#> $exportFormats$`application/vnd.google-apps.script`
#> $exportFormats$`application/vnd.google-apps.script`[[1]]
#> [1] "application/vnd.google-apps.script+json"
#> 
#> 
#> $exportFormats$`application/vnd.google-apps.presentation`
#> $exportFormats$`application/vnd.google-apps.presentation`[[1]]
#> [1] "application/vnd.oasis.opendocument.presentation"
#> 
#> $exportFormats$`application/vnd.google-apps.presentation`[[2]]
#> [1] "application/pdf"
#> 
#> $exportFormats$`application/vnd.google-apps.presentation`[[3]]
#> [1] "application/vnd.openxmlformats-officedocument.presentationml.presentation"
#> 
#> $exportFormats$`application/vnd.google-apps.presentation`[[4]]
#> [1] "text/plain"
#> 
#> 
#> $exportFormats$`application/vnd.google-apps.form`
#> $exportFormats$`application/vnd.google-apps.form`[[1]]
#> [1] "application/zip"
#> 
#> 
#> $exportFormats$`application/vnd.google-apps.drawing`
#> $exportFormats$`application/vnd.google-apps.drawing`[[1]]
#> [1] "image/svg+xml"
#> 
#> $exportFormats$`application/vnd.google-apps.drawing`[[2]]
#> [1] "image/png"
#> 
#> $exportFormats$`application/vnd.google-apps.drawing`[[3]]
#> [1] "application/pdf"
#> 
#> $exportFormats$`application/vnd.google-apps.drawing`[[4]]
#> [1] "image/jpeg"
#> 
#> 
#> $exportFormats$`application/vnd.google-apps.site`
#> $exportFormats$`application/vnd.google-apps.site`[[1]]
#> [1] "text/plain"
#> 
#> 
#> $exportFormats$`application/vnd.google-apps.mail-layout`
#> $exportFormats$`application/vnd.google-apps.mail-layout`[[1]]
#> [1] "text/plain"
#> 
#> 
#> 
#> $maxImportSizes
#> $maxImportSizes$`application/vnd.google-apps.document`
#> [1] "10485760"
#> 
#> $maxImportSizes$`application/vnd.google-apps.spreadsheet`
#> [1] "104857600"
#> 
#> $maxImportSizes$`application/vnd.google-apps.presentation`
#> [1] "104857600"
#> 
#> $maxImportSizes$`application/vnd.google-apps.drawing`
#> [1] "2097152"
#> 
#> 
#> $maxUploadSize
#> [1] "5242880000000"
#> 
#> $appInstalled
#> [1] FALSE
#> 
#> $folderColorPalette
#> $folderColorPalette[[1]]
#> [1] "#ac725e"
#> 
#> $folderColorPalette[[2]]
#> [1] "#d06b64"
#> 
#> $folderColorPalette[[3]]
#> [1] "#f83a22"
#> 
#> $folderColorPalette[[4]]
#> [1] "#fa573c"
#> 
#> $folderColorPalette[[5]]
#> [1] "#ff7537"
#> 
#> $folderColorPalette[[6]]
#> [1] "#ffad46"
#> 
#> $folderColorPalette[[7]]
#> [1] "#fad165"
#> 
#> $folderColorPalette[[8]]
#> [1] "#fbe983"
#> 
#> $folderColorPalette[[9]]
#> [1] "#b3dc6c"
#> 
#> $folderColorPalette[[10]]
#> [1] "#7bd148"
#> 
#> $folderColorPalette[[11]]
#> [1] "#16a765"
#> 
#> $folderColorPalette[[12]]
#> [1] "#42d692"
#> 
#> $folderColorPalette[[13]]
#> [1] "#92e1c0"
#> 
#> $folderColorPalette[[14]]
#> [1] "#9fe1e7"
#> 
#> $folderColorPalette[[15]]
#> [1] "#9fc6e7"
#> 
#> $folderColorPalette[[16]]
#> [1] "#4986e7"
#> 
#> $folderColorPalette[[17]]
#> [1] "#9a9cff"
#> 
#> $folderColorPalette[[18]]
#> [1] "#b99aff"
#> 
#> $folderColorPalette[[19]]
#> [1] "#a47ae2"
#> 
#> $folderColorPalette[[20]]
#> [1] "#cd74e6"
#> 
#> $folderColorPalette[[21]]
#> [1] "#f691b2"
#> 
#> $folderColorPalette[[22]]
#> [1] "#cca6ac"
#> 
#> $folderColorPalette[[23]]
#> [1] "#cabdbf"
#> 
#> $folderColorPalette[[24]]
#> [1] "#8f8f8f"
#> 
#> 
#> $teamDriveThemes
#> $teamDriveThemes[[1]]
#> $teamDriveThemes[[1]]$id
#> [1] "abacus"
#> 
#> $teamDriveThemes[[1]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/abacus_background.jpg"
#> 
#> $teamDriveThemes[[1]]$colorRgb
#> [1] "#ea6100"
#> 
#> 
#> $teamDriveThemes[[2]]
#> $teamDriveThemes[[2]]$id
#> [1] "blueprints"
#> 
#> $teamDriveThemes[[2]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/blueprints_background.jpg"
#> 
#> $teamDriveThemes[[2]]$colorRgb
#> [1] "#4285f4"
#> 
#> 
#> $teamDriveThemes[[3]]
#> $teamDriveThemes[[3]]$id
#> [1] "bok_choy"
#> 
#> $teamDriveThemes[[3]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/bok_choy_background.jpg"
#> 
#> $teamDriveThemes[[3]]$colorRgb
#> [1] "#689f38"
#> 
#> 
#> $teamDriveThemes[[4]]
#> $teamDriveThemes[[4]]$id
#> [1] "books"
#> 
#> $teamDriveThemes[[4]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/books_background.jpg"
#> 
#> $teamDriveThemes[[4]]$colorRgb
#> [1] "#4285f4"
#> 
#> 
#> $teamDriveThemes[[5]]
#> $teamDriveThemes[[5]]$id
#> [1] "bread"
#> 
#> $teamDriveThemes[[5]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/bread_background.jpg"
#> 
#> $teamDriveThemes[[5]]$colorRgb
#> [1] "#ef6c00"
#> 
#> 
#> $teamDriveThemes[[6]]
#> $teamDriveThemes[[6]]$id
#> [1] "bubbles_color"
#> 
#> $teamDriveThemes[[6]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/bubbles_color_background.jpg"
#> 
#> $teamDriveThemes[[6]]$colorRgb
#> [1] "#f06292"
#> 
#> 
#> $teamDriveThemes[[7]]
#> $teamDriveThemes[[7]]$id
#> [1] "circuit"
#> 
#> $teamDriveThemes[[7]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/circuit_background.jpg"
#> 
#> $teamDriveThemes[[7]]$colorRgb
#> [1] "#039be5"
#> 
#> 
#> $teamDriveThemes[[8]]
#> $teamDriveThemes[[8]]$id
#> [1] "clams"
#> 
#> $teamDriveThemes[[8]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/clams_background.jpg"
#> 
#> $teamDriveThemes[[8]]$colorRgb
#> [1] "#e91e63"
#> 
#> 
#> $teamDriveThemes[[9]]
#> $teamDriveThemes[[9]]$id
#> [1] "clovers"
#> 
#> $teamDriveThemes[[9]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/clovers_background.jpg"
#> 
#> $teamDriveThemes[[9]]$colorRgb
#> [1] "#689f38"
#> 
#> 
#> $teamDriveThemes[[10]]
#> $teamDriveThemes[[10]]$id
#> [1] "cocktails"
#> 
#> $teamDriveThemes[[10]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/cocktails_background.jpg"
#> 
#> $teamDriveThemes[[10]]$colorRgb
#> [1] "#db4437"
#> 
#> 
#> $teamDriveThemes[[11]]
#> $teamDriveThemes[[11]]$id
#> [1] "concert"
#> 
#> $teamDriveThemes[[11]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/concert_background.jpg"
#> 
#> $teamDriveThemes[[11]]$colorRgb
#> [1] "#ef6c00"
#> 
#> 
#> $teamDriveThemes[[12]]
#> $teamDriveThemes[[12]]$id
#> [1] "desk"
#> 
#> $teamDriveThemes[[12]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/desk_background.jpg"
#> 
#> $teamDriveThemes[[12]]$colorRgb
#> [1] "#607d8b"
#> 
#> 
#> $teamDriveThemes[[13]]
#> $teamDriveThemes[[13]]$id
#> [1] "donut_coffee"
#> 
#> $teamDriveThemes[[13]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/donut_coffee_background.jpg"
#> 
#> $teamDriveThemes[[13]]$colorRgb
#> [1] "#f06292"
#> 
#> 
#> $teamDriveThemes[[14]]
#> $teamDriveThemes[[14]]$id
#> [1] "fabric_rolls"
#> 
#> $teamDriveThemes[[14]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/fabric_rolls_background.jpg"
#> 
#> $teamDriveThemes[[14]]$colorRgb
#> [1] "#78909c"
#> 
#> 
#> $teamDriveThemes[[15]]
#> $teamDriveThemes[[15]]$id
#> [1] "flags"
#> 
#> $teamDriveThemes[[15]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/flags_background.jpg"
#> 
#> $teamDriveThemes[[15]]$colorRgb
#> [1] "#009688"
#> 
#> 
#> $teamDriveThemes[[16]]
#> $teamDriveThemes[[16]]$id
#> [1] "flower_field"
#> 
#> $teamDriveThemes[[16]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/flower_field_background.jpg"
#> 
#> $teamDriveThemes[[16]]$colorRgb
#> [1] "#e06055"
#> 
#> 
#> $teamDriveThemes[[17]]
#> $teamDriveThemes[[17]]$id
#> [1] "flowers"
#> 
#> $teamDriveThemes[[17]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/flowers_background.jpg"
#> 
#> $teamDriveThemes[[17]]$colorRgb
#> [1] "#689f38"
#> 
#> 
#> $teamDriveThemes[[18]]
#> $teamDriveThemes[[18]]$id
#> [1] "glass"
#> 
#> $teamDriveThemes[[18]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/glass_background.jpg"
#> 
#> $teamDriveThemes[[18]]$colorRgb
#> [1] "#0f9d58"
#> 
#> 
#> $teamDriveThemes[[19]]
#> $teamDriveThemes[[19]]$id
#> [1] "lighthouse"
#> 
#> $teamDriveThemes[[19]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/lighthouse_background.jpg"
#> 
#> $teamDriveThemes[[19]]$colorRgb
#> [1] "#4285f4"
#> 
#> 
#> $teamDriveThemes[[20]]
#> $teamDriveThemes[[20]]$id
#> [1] "maps"
#> 
#> $teamDriveThemes[[20]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/maps_background.jpg"
#> 
#> $teamDriveThemes[[20]]$colorRgb
#> [1] "#8d6e63"
#> 
#> 
#> $teamDriveThemes[[21]]
#> $teamDriveThemes[[21]]$id
#> [1] "mountains"
#> 
#> $teamDriveThemes[[21]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/mountains_background.jpg"
#> 
#> $teamDriveThemes[[21]]$colorRgb
#> [1] "#5c6bc0"
#> 
#> 
#> $teamDriveThemes[[22]]
#> $teamDriveThemes[[22]]$id
#> [1] "notebook"
#> 
#> $teamDriveThemes[[22]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/notebook_background.jpg"
#> 
#> $teamDriveThemes[[22]]$colorRgb
#> [1] "#689f38"
#> 
#> 
#> $teamDriveThemes[[23]]
#> $teamDriveThemes[[23]]$id
#> [1] "paper_colored"
#> 
#> $teamDriveThemes[[23]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/paper_colored_background.jpg"
#> 
#> $teamDriveThemes[[23]]$colorRgb
#> [1] "#9c27b0"
#> 
#> 
#> $teamDriveThemes[[24]]
#> $teamDriveThemes[[24]]$id
#> [1] "pencils"
#> 
#> $teamDriveThemes[[24]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/pencils_background.jpg"
#> 
#> $teamDriveThemes[[24]]$colorRgb
#> [1] "#0097a7"
#> 
#> 
#> $teamDriveThemes[[25]]
#> $teamDriveThemes[[25]]$id
#> [1] "roofing_metal"
#> 
#> $teamDriveThemes[[25]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/roofing_metal_background.jpg"
#> 
#> $teamDriveThemes[[25]]$colorRgb
#> [1] "#039be5"
#> 
#> 
#> $teamDriveThemes[[26]]
#> $teamDriveThemes[[26]]$id
#> [1] "sticky_notes"
#> 
#> $teamDriveThemes[[26]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/sticky_notes_background.jpg"
#> 
#> $teamDriveThemes[[26]]$colorRgb
#> [1] "#0097a7"
#> 
#> 
#> $teamDriveThemes[[27]]
#> $teamDriveThemes[[27]]$id
#> [1] "table"
#> 
#> $teamDriveThemes[[27]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/table_background.jpg"
#> 
#> $teamDriveThemes[[27]]$colorRgb
#> [1] "#8d6e63"
#> 
#> 
#> $teamDriveThemes[[28]]
#> $teamDriveThemes[[28]]$id
#> [1] "travel"
#> 
#> $teamDriveThemes[[28]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/travel_background.jpg"
#> 
#> $teamDriveThemes[[28]]$colorRgb
#> [1] "#039be5"
#> 
#> 
#> $teamDriveThemes[[29]]
#> $teamDriveThemes[[29]]$id
#> [1] "waves"
#> 
#> $teamDriveThemes[[29]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/waves_background.jpg"
#> 
#> $teamDriveThemes[[29]]$colorRgb
#> [1] "#ff5722"
#> 
#> 
#> $teamDriveThemes[[30]]
#> $teamDriveThemes[[30]]$id
#> [1] "waves_blue"
#> 
#> $teamDriveThemes[[30]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/waves_blue_background.jpg"
#> 
#> $teamDriveThemes[[30]]$colorRgb
#> [1] "#5c6bc0"
#> 
#> 
#> $teamDriveThemes[[31]]
#> $teamDriveThemes[[31]]$id
#> [1] "wood"
#> 
#> $teamDriveThemes[[31]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/wood_background.jpg"
#> 
#> $teamDriveThemes[[31]]$colorRgb
#> [1] "#8d6e63"
#> 
#> 
#> 
#> $driveThemes
#> $driveThemes[[1]]
#> $driveThemes[[1]]$id
#> [1] "abacus"
#> 
#> $driveThemes[[1]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/abacus_background.jpg"
#> 
#> $driveThemes[[1]]$colorRgb
#> [1] "#ea6100"
#> 
#> 
#> $driveThemes[[2]]
#> $driveThemes[[2]]$id
#> [1] "blueprints"
#> 
#> $driveThemes[[2]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/blueprints_background.jpg"
#> 
#> $driveThemes[[2]]$colorRgb
#> [1] "#4285f4"
#> 
#> 
#> $driveThemes[[3]]
#> $driveThemes[[3]]$id
#> [1] "bok_choy"
#> 
#> $driveThemes[[3]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/bok_choy_background.jpg"
#> 
#> $driveThemes[[3]]$colorRgb
#> [1] "#689f38"
#> 
#> 
#> $driveThemes[[4]]
#> $driveThemes[[4]]$id
#> [1] "books"
#> 
#> $driveThemes[[4]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/books_background.jpg"
#> 
#> $driveThemes[[4]]$colorRgb
#> [1] "#4285f4"
#> 
#> 
#> $driveThemes[[5]]
#> $driveThemes[[5]]$id
#> [1] "bread"
#> 
#> $driveThemes[[5]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/bread_background.jpg"
#> 
#> $driveThemes[[5]]$colorRgb
#> [1] "#ef6c00"
#> 
#> 
#> $driveThemes[[6]]
#> $driveThemes[[6]]$id
#> [1] "bubbles_color"
#> 
#> $driveThemes[[6]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/bubbles_color_background.jpg"
#> 
#> $driveThemes[[6]]$colorRgb
#> [1] "#f06292"
#> 
#> 
#> $driveThemes[[7]]
#> $driveThemes[[7]]$id
#> [1] "circuit"
#> 
#> $driveThemes[[7]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/circuit_background.jpg"
#> 
#> $driveThemes[[7]]$colorRgb
#> [1] "#039be5"
#> 
#> 
#> $driveThemes[[8]]
#> $driveThemes[[8]]$id
#> [1] "clams"
#> 
#> $driveThemes[[8]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/clams_background.jpg"
#> 
#> $driveThemes[[8]]$colorRgb
#> [1] "#e91e63"
#> 
#> 
#> $driveThemes[[9]]
#> $driveThemes[[9]]$id
#> [1] "clovers"
#> 
#> $driveThemes[[9]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/clovers_background.jpg"
#> 
#> $driveThemes[[9]]$colorRgb
#> [1] "#689f38"
#> 
#> 
#> $driveThemes[[10]]
#> $driveThemes[[10]]$id
#> [1] "cocktails"
#> 
#> $driveThemes[[10]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/cocktails_background.jpg"
#> 
#> $driveThemes[[10]]$colorRgb
#> [1] "#db4437"
#> 
#> 
#> $driveThemes[[11]]
#> $driveThemes[[11]]$id
#> [1] "concert"
#> 
#> $driveThemes[[11]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/concert_background.jpg"
#> 
#> $driveThemes[[11]]$colorRgb
#> [1] "#ef6c00"
#> 
#> 
#> $driveThemes[[12]]
#> $driveThemes[[12]]$id
#> [1] "desk"
#> 
#> $driveThemes[[12]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/desk_background.jpg"
#> 
#> $driveThemes[[12]]$colorRgb
#> [1] "#607d8b"
#> 
#> 
#> $driveThemes[[13]]
#> $driveThemes[[13]]$id
#> [1] "donut_coffee"
#> 
#> $driveThemes[[13]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/donut_coffee_background.jpg"
#> 
#> $driveThemes[[13]]$colorRgb
#> [1] "#f06292"
#> 
#> 
#> $driveThemes[[14]]
#> $driveThemes[[14]]$id
#> [1] "fabric_rolls"
#> 
#> $driveThemes[[14]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/fabric_rolls_background.jpg"
#> 
#> $driveThemes[[14]]$colorRgb
#> [1] "#78909c"
#> 
#> 
#> $driveThemes[[15]]
#> $driveThemes[[15]]$id
#> [1] "flags"
#> 
#> $driveThemes[[15]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/flags_background.jpg"
#> 
#> $driveThemes[[15]]$colorRgb
#> [1] "#009688"
#> 
#> 
#> $driveThemes[[16]]
#> $driveThemes[[16]]$id
#> [1] "flower_field"
#> 
#> $driveThemes[[16]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/flower_field_background.jpg"
#> 
#> $driveThemes[[16]]$colorRgb
#> [1] "#e06055"
#> 
#> 
#> $driveThemes[[17]]
#> $driveThemes[[17]]$id
#> [1] "flowers"
#> 
#> $driveThemes[[17]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/flowers_background.jpg"
#> 
#> $driveThemes[[17]]$colorRgb
#> [1] "#689f38"
#> 
#> 
#> $driveThemes[[18]]
#> $driveThemes[[18]]$id
#> [1] "glass"
#> 
#> $driveThemes[[18]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/glass_background.jpg"
#> 
#> $driveThemes[[18]]$colorRgb
#> [1] "#0f9d58"
#> 
#> 
#> $driveThemes[[19]]
#> $driveThemes[[19]]$id
#> [1] "lighthouse"
#> 
#> $driveThemes[[19]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/lighthouse_background.jpg"
#> 
#> $driveThemes[[19]]$colorRgb
#> [1] "#4285f4"
#> 
#> 
#> $driveThemes[[20]]
#> $driveThemes[[20]]$id
#> [1] "maps"
#> 
#> $driveThemes[[20]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/maps_background.jpg"
#> 
#> $driveThemes[[20]]$colorRgb
#> [1] "#8d6e63"
#> 
#> 
#> $driveThemes[[21]]
#> $driveThemes[[21]]$id
#> [1] "mountains"
#> 
#> $driveThemes[[21]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/mountains_background.jpg"
#> 
#> $driveThemes[[21]]$colorRgb
#> [1] "#5c6bc0"
#> 
#> 
#> $driveThemes[[22]]
#> $driveThemes[[22]]$id
#> [1] "notebook"
#> 
#> $driveThemes[[22]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/notebook_background.jpg"
#> 
#> $driveThemes[[22]]$colorRgb
#> [1] "#689f38"
#> 
#> 
#> $driveThemes[[23]]
#> $driveThemes[[23]]$id
#> [1] "paper_colored"
#> 
#> $driveThemes[[23]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/paper_colored_background.jpg"
#> 
#> $driveThemes[[23]]$colorRgb
#> [1] "#9c27b0"
#> 
#> 
#> $driveThemes[[24]]
#> $driveThemes[[24]]$id
#> [1] "pencils"
#> 
#> $driveThemes[[24]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/pencils_background.jpg"
#> 
#> $driveThemes[[24]]$colorRgb
#> [1] "#0097a7"
#> 
#> 
#> $driveThemes[[25]]
#> $driveThemes[[25]]$id
#> [1] "roofing_metal"
#> 
#> $driveThemes[[25]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/roofing_metal_background.jpg"
#> 
#> $driveThemes[[25]]$colorRgb
#> [1] "#039be5"
#> 
#> 
#> $driveThemes[[26]]
#> $driveThemes[[26]]$id
#> [1] "sticky_notes"
#> 
#> $driveThemes[[26]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/sticky_notes_background.jpg"
#> 
#> $driveThemes[[26]]$colorRgb
#> [1] "#0097a7"
#> 
#> 
#> $driveThemes[[27]]
#> $driveThemes[[27]]$id
#> [1] "table"
#> 
#> $driveThemes[[27]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/table_background.jpg"
#> 
#> $driveThemes[[27]]$colorRgb
#> [1] "#8d6e63"
#> 
#> 
#> $driveThemes[[28]]
#> $driveThemes[[28]]$id
#> [1] "travel"
#> 
#> $driveThemes[[28]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/travel_background.jpg"
#> 
#> $driveThemes[[28]]$colorRgb
#> [1] "#039be5"
#> 
#> 
#> $driveThemes[[29]]
#> $driveThemes[[29]]$id
#> [1] "waves"
#> 
#> $driveThemes[[29]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/waves_background.jpg"
#> 
#> $driveThemes[[29]]$colorRgb
#> [1] "#ff5722"
#> 
#> 
#> $driveThemes[[30]]
#> $driveThemes[[30]]$id
#> [1] "waves_blue"
#> 
#> $driveThemes[[30]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/waves_blue_background.jpg"
#> 
#> $driveThemes[[30]]$colorRgb
#> [1] "#5c6bc0"
#> 
#> 
#> $driveThemes[[31]]
#> $driveThemes[[31]]$id
#> [1] "wood"
#> 
#> $driveThemes[[31]]$backgroundImageLink
#> [1] "https://ssl.gstatic.com/team_drive_themes/wood_background.jpg"
#> 
#> $driveThemes[[31]]$colorRgb
#> [1] "#8d6e63"
#> 
#> 
#> 
#> $canCreateTeamDrives
#> [1] FALSE
#> 
#> $canCreateDrives
#> [1] FALSE
#> 

# explore the export formats available for Drive files, by MIME type
about <- drive_about()
about[["exportFormats"]] |>
  purrr::map(unlist)
#> $`application/vnd.google-apps.document`
#>  [1] "application/rtf"                                                        
#>  [2] "application/vnd.oasis.opendocument.text"                                
#>  [3] "text/html"                                                              
#>  [4] "application/pdf"                                                        
#>  [5] "text/x-markdown"                                                        
#>  [6] "text/markdown"                                                          
#>  [7] "application/epub+zip"                                                   
#>  [8] "application/zip"                                                        
#>  [9] "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
#> [10] "text/plain"                                                             
#> 
#> $`application/vnd.google-apps.vid`
#> [1] "video/mp4"
#> 
#> $`application/vnd.google-apps.spreadsheet`
#> [1] "application/x-vnd.oasis.opendocument.spreadsheet"                 
#> [2] "text/tab-separated-values"                                        
#> [3] "application/pdf"                                                  
#> [4] "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
#> [5] "text/csv"                                                         
#> [6] "application/zip"                                                  
#> [7] "application/vnd.oasis.opendocument.spreadsheet"                   
#> 
#> $`application/vnd.google-apps.jam`
#> [1] "application/pdf"
#> 
#> $`application/vnd.google-apps.script`
#> [1] "application/vnd.google-apps.script+json"
#> 
#> $`application/vnd.google-apps.presentation`
#> [1] "application/vnd.oasis.opendocument.presentation"                          
#> [2] "application/pdf"                                                          
#> [3] "application/vnd.openxmlformats-officedocument.presentationml.presentation"
#> [4] "text/plain"                                                               
#> 
#> $`application/vnd.google-apps.form`
#> [1] "application/zip"
#> 
#> $`application/vnd.google-apps.drawing`
#> [1] "image/svg+xml"   "image/png"       "application/pdf"
#> [4] "image/jpeg"     
#> 
#> $`application/vnd.google-apps.site`
#> [1] "text/plain"
#> 
#> $`application/vnd.google-apps.mail-layout`
#> [1] "text/plain"
#> 
```
