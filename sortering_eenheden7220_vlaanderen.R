# remotes::install_github("inbo/n2khab") # zie https://inbo.github.io/n2khab/
renv::restore()
options(rgdal_show_exportToProj4_warnings = "none")
library(n2khab)
library(dplyr)
library(readr)
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

# bounding box voor de 7220 eenheden in Haspengouw:
bbox_zlimb <- st_bbox(c(xmin = 2.05e5,
                        xmax = 2.4e5,
                        ymin = 15.5e4,
                        ymax = 17e4),
                      crs = st_crs(31370))

units_7220_ranked <-
  units_7220_ranked %>%
  # opvullen ontbrekende GRTS rank:
  mutate(grts_address = ifelse(unit_id %in% border_cases$unit_id,
                            border_cases %>%
                              filter(unit_id == unit_id) %>%
                              pull(grts_address),
                            grts_address)) %>%
  # sorteren volgens GRTS rank:
  arrange(grts_address) %>%
  mutate(grts_rank = rank(grts_address),
         .after = grts_address) %>%
  st_join(bbox_zlimb %>%
            st_as_sfc %>%
            st_as_sf(haspengouw = TRUE)) %>%
    mutate(grts_rank_haspengouw = dense_rank(grts_address * haspengouw),
           haspengouw = !is.na(haspengouw)) %>%
    relocate(haspengouw, grts_rank_haspengouw,
           .after = grts_rank)


# Overeenkomstige 7220-punten (= subniveau van 'units') in habitatsprings:

points_7220_ranked <-
  read_habitatsprings(filter_hab = TRUE) %>%
  inner_join(units_7220_ranked %>%
               st_drop_geometry %>%
               select(unit_id,
                      matches("grts|hasp")),
             by = "unit_id") %>%
  relocate(matches("grts|hasp"), .after = unit_id) %>%
  arrange(grts_address, point_id)

points_7220_ranked %>%
  filter(haspengouw)

# Wegschrijven van de resultaten:

if (!dir.exists("output")) dir.create("output")

units_7220_ranked %>% st_write("output/type7220_ranked.gpkg",
                               layer = "units_7220_ranked",
                               delete_dsn = TRUE)
points_7220_ranked %>% st_write("output/type7220_ranked.gpkg",
                               layer = "points_7220_ranked")
units_7220_ranked %>%
  filter(haspengouw) %>%
  st_write("output/type7220_haspengouw_ranked.gpkg",
                               layer = "units_7220_haspengouw_ranked",
                               delete_dsn = TRUE)
points_7220_ranked %>%
  filter(haspengouw) %>%
  st_write("output/type7220_haspengouw_ranked.gpkg",
                                layer = "points_7220_haspengouw_ranked")


units_7220_ranked %>% st_write("output/units_7220_ranked.shp",
                               delete_dsn = TRUE)
points_7220_ranked %>% st_write("output/points_7220_ranked.shp",
                               delete_dsn = TRUE)
units_7220_ranked %>%
  filter(haspengouw) %>%
  st_write("output/units_7220_haspengouw_ranked.shp",
                               delete_dsn = TRUE)
points_7220_ranked %>%
  filter(haspengouw) %>%
  st_write("output/points_7220_haspengouw_ranked.shp",
                                delete_dsn = TRUE)
# Laatste versie van gpkg & shp: zie GDrive link in README.
  # Shapefile is een formaat met afgekapte veldnamen.

  # GeoJSON files voor bewaring in de git repo:

units_7220_ranked %>% st_write("output/units_7220_ranked.geojson",
                               layer_options = "RFC7946=YES",
                               delete_dsn = TRUE)

units_7220_ranked %>%
  filter(haspengouw) %>%
  st_write("output/units_7220_haspengouw_ranked.geojson",
           layer_options = "RFC7946=YES",
           delete_dsn = TRUE)

points_7220_ranked %>% st_write("output/points_7220_ranked.geojson",
                                layer_options = "RFC7946=YES",
                                delete_dsn = TRUE)

points_7220_ranked %>%
  filter(haspengouw) %>%
  st_write("output/points_7220_haspengouw_ranked.geojson",
           layer_options = "RFC7946=YES",
           delete_dsn = TRUE)

  # tsv files met attributen:

units_7220_ranked %>%
  mutate(x = st_coordinates(.)[,1],
         y = st_coordinates(.)[,2]) %>%
  st_drop_geometry %>%
  relocate(x, y, .after = 1) %>%
  write_tsv("output/units_7220_ranked.tsv")

units_7220_ranked %>%
  filter(haspengouw) %>%
  mutate(x = st_coordinates(.)[,1],
         y = st_coordinates(.)[,2]) %>%
  st_drop_geometry %>%
  relocate(x, y, .after = 1) %>%
  write_tsv("output/units_7220_haspengouw_ranked.tsv")

points_7220_ranked %>%
  mutate(x = st_coordinates(.)[,1],
         y = st_coordinates(.)[,2]) %>%
  st_drop_geometry %>%
  relocate(x, y, .after = 1) %>%
  write_tsv("output/points_7220_ranked.tsv")

points_7220_ranked %>%
  filter(haspengouw) %>%
  mutate(x = st_coordinates(.)[,1],
         y = st_coordinates(.)[,2]) %>%
  st_drop_geometry %>%
  relocate(x, y, .after = 1) %>%
  write_tsv("output/points_7220_haspengouw_ranked.tsv")

# Een GeoJSON inlezen en transformeren naar CRS 'Belge 1972 / Belgian Lambert 72':
read_sf("output/units_7220_haspengouw_ranked.geojson") %>%
  st_transform(31370)

# Units op kaart:

mapview(units_7220_ranked %>% filter(haspengouw),
        layer.name = "units_7220",
        zcol = "grts_rank_haspengouw",
        alpha.regions = 1,
        label = "grts_rank_haspengouw")

units_7220_ranked %>%
  filter(haspengouw) %>%
  mutate(grts_address = factor(grts_address)) %>%
  ggplot() +
  geom_sf(data = flanders, fill = NA) +
  geom_sf(aes(fill = grts_address),
          size = 3,
          shape = 21) +
  coord_sf(datum = 31370) +
  theme_bw() +
  lims(x = c(bbox_zlimb$xmin, bbox_zlimb$xmax),
       y = c(bbox_zlimb$ymin, bbox_zlimb$ymax))


