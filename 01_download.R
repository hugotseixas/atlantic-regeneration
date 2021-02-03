# HEADER ----------------------------------------------------------------------
#
# Title:        Download layers
# Description:  The script uses the GEE api from {rgee} to access, process
#               and download the spatial data required to perform the 
#               experiment.  
#
# Authors:      Hugo Tameirao Seixas, Marcelo Bandoria
# Contact:      tameirao.hugo@gmail.com, marcelobandoria@gmail.com
# Date:         2021-25-01
#
# Notes:        In order to run this routine, you will need to have access
#               to Google Earth Engine (https://earthengine.google.com/).
#               You will also need to install and configure the {rgee} package,
#               Installation and use guide can be found in:
#               https://r-spatial.github.io/rgee/        
#
# LIBRARIES -------------------------------------------------------------------
#
library(geojson)
library(geojsonsf)
library(rgee)
library(sf)
library(geobr)
library(dplyr)
library(purrr)
#
# OPTIONS ---------------------------------------------------------------------
#
gee_email <- "hugo.seixas@alumni.usp.br"
#
# START GEE API ---------------------------------------------------------------

## Initialize GEE ----
ee_Initialize(email = gee_email, drive = TRUE)

# LOAD DATA -------------------------------------------------------------------

## Load Mata Atlântica polygon ----
biome <-
  read_biomes() %>%
  filter(name_biome == "Mata Atlântica")

# Upload to GEE
biome <- sf_as_ee(biome)

## Load secondary forest age data ----
sec_forest <- 
  ee$Image("users/celsohlsj/public/secondary_forest_age_collection41_v2")$
  selfMask()

## Load primary forests ----

# Load Mapbiomas
mapbiomas <-
  ee$Image(
    paste0(
      "projects/mapbiomas-workspace/public/",
      "collection5/mapbiomas_collection50_integration_v1"
    )
  )

# Get bands from mapbiomas
bands <- mapbiomas$bandNames()$getInfo()

# Extract primary forests
prim_forest <-
  ee$ImageCollection$fromImages(
    map(bands, function(band_name) {
      values <- c(3, -1) # The "-1" avoids an error with ee.List())
      return(
        mapbiomas$
          select(band_name)$
          remap(
            from = values,
            to = rep(1, length(values)),
            defaultValue = 0
          )
      )
    })
  )$
  reduce(ee$Reducer$allNonZero())$
  selfMask()
