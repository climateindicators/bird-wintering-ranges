# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-bird-wintering-ranges/index.html>  \
  sha256 `1a853423498b20a276251c878caec6c9f75c79de4bc861e0e60b9d27ad759ae4`

Technical documentation: <https://19january2025snapshot.epa.gov/system/files/documents/2024-08/bird-ranges_documentation.pdf>

## Figure data

- `bird-ranges_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/sites/default/files/2016-08/bird-ranges_fig-1.csv>  \
  sha256 `b2c9432fdef5003a74fc6c5c4eb6a9f7d9337053325ac61ee5d9e16265a1b099`  \
  encoding UTF-8, 48 data rows, columns: `year`, `mean distance (miles)`, `lower confidence (miles)`, `upper confidence (miles)`  \
  title: Figure 1. Change in Latitude of Bird Center of Abundance, 1966-2013  \
  data source: National Audubon Society, 2014; web update: May 2014; units: Average distance moved north (miles)

- `bird-ranges_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/sites/default/files/2016-08/bird-ranges_fig-2.csv>  \
  sha256 `9a27f326cdbe4bd3ed42967e99ad883b8cf4401c3e55abc85ce3fa6612cb5020`  \
  encoding UTF-8, 48 data rows, columns: `year`, `mean distance (miles)`, `lower confidence (miles)`, `upper confidence (miles)`  \
  title: Figure 2. Change in Distance to Coast of Bird Center of Abundance, 1966-2013  \
  data source: National Audubon Society, 2014; web update: May 2014; units: Average distance moved inland from coast (miles)
