# Regression checks on the generated data for the Bird Wintering Ranges indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 2 dataset(s)", length(meta$datasets) == 2L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")
# Pins the numbers so a data update fails here and says what changed. Values are
# compared as strings to keep the source precision.
snapshot <- function(file, rows, first, last, ranges) {
  d <- rd(file)
  check(sprintf("%s: %d rows", file, rows), nrow(d) == rows)
  check(sprintf("%s: first row", file), identical(unlist(d[1, ]), first))
  check(sprintf("%s: last row", file), identical(unlist(d[nrow(d), ]), last))
  for (s in names(ranges)) {
    v <- d$value[d$series == s]
    n <- as.numeric(v)
    check(sprintf("%s: %s min", file, s), identical(v[which.min(n)], ranges[[s]][1]))
    check(sprintf("%s: %s max", file, s), identical(v[which.max(n)], ranges[[s]][2]))
    check(sprintf("%s: %s covers 1966-2013", file, s),
          identical(d$year[d$series == s], as.character(1966:2013)))
  }
}

snapshot("bird_center_latitude_change.csv", 144L,
         c(year = "1966", series = "mean", value = "0"),
         c(year = "2013", series = "upper_confidence", value = "62.78622154"),
         list(mean             = c("-1.259309975", "45.24713787"),
              lower_confidence = c("-7.502975833", "26.649291"),
              upper_confidence = c("0", "66.63876502")))

snapshot("bird_center_coast_distance_change.csv", 144L,
         c(year = "1966", series = "mean", value = "0"),
         c(year = "2013", series = "upper_confidence", value = "22.75034037"),
         list(mean             = c("-6.64391639", "13.42922869"),
              lower_confidence = c("-11.65548914", "4.108117005"),
              upper_confidence = c("-1.632343644", "22.75034037")))

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
