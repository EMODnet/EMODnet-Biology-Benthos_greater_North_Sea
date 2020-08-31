# stand alone static map example
# remotes::install_github("vlizbe/imis")
# remotes::install_github("lifewatch/eurobis")

library(eurobis)
library(ggplot2)
library('rnaturalearth')
library(magick)

# This test relies on produce_maps.R
# Run the code inside the loop on L104 setting first ss = 1. DO NOT RUN THE LOOP ITSELF
# Run from line 105 to 133
# Here a saved version of r1 will be loaded
r1 <- readRDS(file.path(".", "scripts", "test_maps", "r1.rds"))

# Show countries
world <- ne_countries(scale = "medium", returnclass = "sf")

# EMODnet colors
emodnetColor <- list(
  # First palette
  blue = "#0A71B4",
  yellow = "#F8B334",
  darkgrey = "#333333",
  # Secondary palette,
  darkblue = "#012E58",
  lightblue = "#61AADF",
  white = "#FFFFFF",
  lightgrey = "#F9F9F9"
)

# EMODnet logo
logo_raw <- image_read("https://www.emodnet-biology.eu/sites/emodnet-biology.eu/files/public/logos/logo-footer.png") 

# Transform raster to vector
grid <- sf::st_as_sf(raster::rasterToPolygons(r1))
grid_bbox <- sf::st_bbox(sf::st_transform(grid, 3035))

# Plot the grid
plot_grid <- ggplot() +
  geom_sf(data = world, 
          fill = emodnetColor$darkgrey, 
          color = emodnetColor$lightgrey, 
          size = 0.1) +
  geom_sf(data = grid, aes(fill = layer), size = 0.05) +
  coord_sf(crs = 3035, xlim = c(grid_bbox$xmin, grid_bbox$xmax), ylim = c(grid_bbox$ymin, grid_bbox$ymax)) +
  scale_fill_viridis_c(alpha = 1, begin = 1, end = 0, direction = -1) +
  ggtitle("specname",
          subtitle = paste0('AphiaID ', "spAphId")) +
  theme(
    panel.background = element_rect(fill = emodnetColor$lightgrey),
    plot.title = element_text(color= emodnetColor$darkgrey, size = 14, face="bold.italic", hjust = 0.5),
    plot.subtitle = element_text(color= emodnetColor$darkgrey, face="bold", size=10, hjust = 0.5)
  )

# Inspect plot
plot_grid

# Save plot
ggsave(filename = file.path(".", "scripts", "test_maps", "map_test.png"),
       width = 198.4375, height = 121.70833333, dpi = 300, units = "mm")

# Add emodnet logo
plot <- image_read(file.path(".", "scripts", "test_maps", "map_test.png"))
logo <- logo_raw %>% image_scale("150")
final_plot <- image_composite(plot, logo, gravity = "northeast", offset = "+680+220")
image_write(final_plot, file.path(".", "scripts", "test_maps", "map_test.png"))

            