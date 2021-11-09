require(tidycensus)
require(ggplot2)
require(rayshader)
require(scales)
require(ggthemes)
require(sf)
require(dplyr)
require(colorspace)

census_api_key(key = Sys.getenv('census'))

vars <- load_variables(2020, "pl")

total_pop <- get_decennial(year = 2020, variables = "P1_001N", state = 42, county = 3, geography = "block group", geometry = TRUE) %>%
  mutate(area = st_area(geometry),
         area = as.numeric(area),
         pop_density = value / area)

mp <- ggplot(data = total_pop, aes(fill = value, color = value)) +
  geom_sf() +
  theme_map() +
  labs(fill = "Population", color = "Population") +
  theme(legend.position="bottom")

mp

plot_gg(mp, multicore=TRUE, width=5 ,height=5, scale=250)
render_movie("img/alco_blckgrp.mp4", frames = 720, fps=30, zoom=0.6, fov = 30)
render_snapshot(clear = TRUE)

den <- ggplot(data = total_pop, aes(fill = pop_density)) +
  geom_sf(color = NA) +
  theme_map() +
  labs(fill = "Population Density") +
  scale_fill_distiller(palette = "RdYlGn") +
  theme(legend.position="bottom")

den

render_snapshot(clear = TRUE)
plot_gg(den, multicore=TRUE, width=5 ,height=5, scale=250)
render_snapshot()
save_3dprint("alo_densitry.stl", clear=TRUE)

plot_gg(den, multicore=TRUE, width=5 ,height=5, scale=250)
render_movie("img/alco_den_blckgrp.mp4", frames = 720, fps=30, zoom=0.6, fov = 30, phi = 25, title_text = "Allegheny County Pop. Density", title_color = "black")
render_snapshot(clear = TRUE)

pop_muni <- get_decennial(year = 2020, variables = "P1_001N", state = 42, county = 3, geography = "county subdivision", geometry = TRUE) %>%
  mutate(area = st_area(geometry),
         area = as.numeric(area),
         pop_density = value / area)

muni <- ggplot(data = pop_muni, aes(fill = value)) +
  geom_sf() +
  theme_map() +
  labs(fill = "Population")

plot_gg(muni, multicore=TRUE, width=5 ,height=5, scale=250)
render_movie("img/alco_muni.mp4", frames = 720, fps=30, zoom=0.6, fov = 30)
render_snapshot(clear = TRUE)

pop_pa <- get_decennial(year = 2020, variables = "P1_001N", state = 42, geography = "block group", geometry = TRUE) %>%
  mutate(area = st_area(geometry),
         area = as.numeric(area),
         pop_density = value / area)

pa <- ggplot(data = pop_pa, aes(fill = value, color = value)) +
  geom_sf() +
  theme_map() +
  labs(fill = "Population", color = "Population") +
  theme(legend.position="bottom")

plot_gg(pa, multicore=TRUE, width=5 ,height=5, scale=250)
render_movie("img/pa_blckgrp.mp4", frames = 720, fps=30, zoom=0.85, fov = 30)
render_snapshot(clear = TRUE)

pa_den <- ggplot(data = pop_pa, aes(fill = pop_density)) +
  geom_sf(color = NA) +
  theme_map() +
  labs(fill = "Population Density") +
  scale_fill_distiller(palette = "RdYlGn") +
  theme(legend.position="bottom")

plot_gg(pa_den, multicore=TRUE, width=5 ,height=5, scale=250)
render_movie("img/pa_den_blckgrp.mp4", frames = 720, fps=30, zoom=.45, fov = 30, phi = 20, title_text = "Pennsylvania Population Density", title_color = "black")
render_snapshot(clear = TRUE)

rgl::rgl.close()