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
  ee$Image("users/celsohlsj/public/secondary_forest_age_collection41_v2")

## Load primary forests ----

# Load Mapbiomas
mapbiomas <-
  ee$Image(
    paste0(
      "projects/mapbiomas-workspace/public/",
      "collection4_1/mapbiomas_collection41_integration_v1"
    )
  )

# Get bands from mapbiomas
bands <- mapbiomas$bandNames()$getInfo()

# CREATE MASK -----------------------------------------------------------------

## Create primary forests mask ----
# Only pixels which contains only forest in the time series
prim_forest_mask <-
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
  reduce(ee$Reducer$allNonZero())

# Expand primary forest mask
expanded_mask <- prim_forest_mask$focal_max(radius = 10)

## Create secondary forest mask ----
# Pixels that presented secondary forest at any year
sec_forest_mask <-
  ee$ImageCollection$fromImages(
    map(
      sec_forest$bandNames()$getInfo(), 
      function(band_name) {
        return(
          sec_forest$
            select(band_name)$
            remap(
              from = list(0),
              to = list(0),
              defaultValue = 1
            )
        )
      }
    )
  )$
  reduce(ee$Reducer$anyNonZero())

## Create buffer between masks ----
sec_forest_mask <- 
  sec_forest_mask$updateMask(
    prim_forest_mask$focal_max(radius = 10)$
      subtract(prim_forest_mask)$
      eq(0)
  )
