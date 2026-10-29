# Creates inst/extdata/example_files/chicken.jpg and chicken.pdf
#
# Source image:
#   Charles Jacque (French, 1813-1894), "From The Henhouse", 1858
#   Wood engraving
#   The Metropolitan Museum of Art, Gift of Howard Mansfield, 1927
#   https://www.metmuseum.org/art/collection/search/832363
#   Public domain, released by The Met under CC0 (Open Access)
#
# Processing: crop to the hen (dropping the museum stamp and most of the blank
# sheet), convert to grayscale, scale to 400 px wide, save as JPEG quality 70.
# The PDF is made from that JPG with macOS `sips`, because ImageMagick's PDF
# output was about twice the size.

library(here)
library(magick)

src_url <- "https://images.metmuseum.org/CRDImages/dp/original/DP888888.jpg"
src <- withr::local_tempfile(fileext = ".jpg")
download.file(src_url, src, mode = "wb")

out_dir <- here("inst", "extdata", "example_files")
jpg_path <- file.path(out_dir, "chicken.jpg")
pdf_path <- file.path(out_dir, "chicken.pdf")

# Crop geometry is in pixels of the 1997x2328 original
image_read(src) |>
  image_crop("1000x1100+500+800") |>
  image_convert(colorspace = "gray") |>
  image_scale("400") |>
  image_write(jpg_path, format = "jpeg", quality = 70)

stopifnot(Sys.info()[["sysname"]] == "Darwin")
system2("sips", c("-s", "format", "pdf", jpg_path, "--out", pdf_path))

file.size(c(jpg_path, pdf_path))
