# remotes::install_github("inbo/n2khab") # zie https://inbo.github.io/n2khab/
options(rgdal_show_exportToProj4_warnings = "none")
library(n2khab)
library(dplyr)
library(sf)
library(ggplot2)
library(mapview)

GRTSmh <- read_GRTSmh()
flanders <- read_admin_areas()
flanders_buffer <- flanders %>% st_buffer(40)
units_7220_ranked <-
  read_habitatsprings(units_7220 = TRUE) %>%  # zie https://inbo.github.io/n2khab/reference/read_habitatsprings.html
  .[flanders_buffer,] %>%
  mutate(grts_address = GRTSmh[as_Spatial(.)]) %>%
  relocate(grts_address, .after = unit_id)

# 1 locatie valt buiten de range van het GRTS mastergrid;
# we gebruiken het GRTS adres van de nabijgelegen cel
border_cases <-
  units_7220_ranked %>%
  filter(is.na(grts_address)) %>%
  st_buffer(20) %>%
  mutate(grts_address =
           GRTSmh[as_Spatial(.), drop=FALSE][] %>%
           .[!is.na(.)]) %>%
  select(unit_id, grts_address) %>%
  st_drop_geometry()

units_7220_ranked <-
  units_7220_ranked %>%
  # opvullen ontbrekende GRTS rank:
  mutate(grts_address = ifelse(unit_id %in% border_cases$unit_id,
                            border_cases %>%
                              filter(unit_id == unit_id) %>%
                              pull(grts_address),
                            grts_address)) %>%
  # sorteren volgens GRTS rank:
  arrange(grts_address)

units_7220_ranked %>% st_write("units_7220_ranked.gpkg",
                               delete_dsn = TRUE)
units_7220_ranked %>% st_write("units_7220_ranked.geojson",
                               layer_options = "RFC7946=YES",
                               delete_dsn = TRUE)
units_7220_ranked %>% st_write("units_7220_ranked.shp",
                               delete_dsn = TRUE)

# op kaart:

mapview(units_7220_ranked, zcol = "grts_address")

ggplot(units_7220_ranked) +
  geom_sf(data = flanders, fill = NA) +
  geom_sf(aes(colour = grts_address)) +
  coord_sf(datum = 31370) +
  theme_bw() +
  lims(x = c(2.05e5, 2.4e5), y = c(15.5e4, 17e4))

bbox_zlimb <- st_bbox(c(xmin = 2.05e5,
                        xmax = 2.4e5,
                        ymin = 15.5e4,
                        ymax = 17e4),
                      crs = st_crs(31370))

units_7220_ranked %>%
  st_intersection(st_as_sfc(bbox_zlimb)) %>%
  select(1:6)


