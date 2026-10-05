# Build tidy long-format data for the Bird Wintering Ranges indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# Each figure is reshaped to long format: year, series, value.\n#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# One row per year and series. Series are matched by header string, never by
# position. Values stay character so the source precision survives.
SERIES <- c(
  "mean distance (miles)"     = "mean",
  "lower confidence (miles)"  = "lower_confidence",
  "upper confidence (miles)"  = "upper_confidence"
)

to_long <- function(raw) {
  out <- do.call(rbind, lapply(names(SERIES), function(h) {
    data.frame(year = raw$year, series = unname(SERIES[h]), value = raw[[h]],
               stringsAsFactors = FALSE)
  }))
  assert_conservation(raw, names(SERIES), nrow(out), "to_long")
  out
}

# ---- Indicator constants
INDICATOR <- list(
  name                    = "Bird Wintering Ranges",
  slug                    = "bird-wintering-ranges",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-bird-wintering-ranges/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/system/files/documents/2024-08/bird-ranges_documentation.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: Change in Latitude of Bird Center of Abundance, 1966-2013 ----

f1_path <- file.path(raw_dir, "bird-ranges_fig-1.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f1_raw,
  id_cols          = "year",
  expected_headers = c("mean distance (miles)", "lower confidence (miles)", "upper confidence (miles)"),
  what             = "bird-ranges_fig-1.csv"
)

f1 <- to_long(f1_raw)

write_csv_stable(f1, file.path(out_dir, "bird_center_latitude_change.csv"))

# ---- Figure 2: Change in Distance to Coast of Bird Center of Abundance, 1966-2013 ----

f2_path <- file.path(raw_dir, "bird-ranges_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f2_raw,
  id_cols          = "year",
  expected_headers = c("mean distance (miles)", "lower confidence (miles)", "upper confidence (miles)"),
  what             = "bird-ranges_fig-2.csv"
)

f2 <- to_long(f2_raw)

write_csv_stable(f2, file.path(out_dir, "bird_center_coast_distance_change.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

# One entry per output column, in order.\ndescribe <- function(df, unit) {\n  docs <- list(\n    year   = col("year", "integer", "Calendar year of the winter estimate"),\n    series = col("series", "string", "mean, lower_confidence or upper_confidence (bounds of the likely range around the mean)"),\n    value  = col("value", "number", paste0(unit, " (change from the 1966 baseline)"))\n  )\n  unname(docs[names(df)])\n}\n
meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "bird_center_latitude_change.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "bird-ranges_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "UTF-8",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = describe(f1, f1_meta$units)
    ),
    list(
      file            = "bird_center_coast_distance_change.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "bird-ranges_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = "UTF-8",
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns         = describe(f2, f2_meta$units)
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
