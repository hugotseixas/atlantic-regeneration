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
library(rgee)
library(sf)
library(geobr)
#
# OPTIONS ---------------------------------------------------------------------
#
gee_email = "hugo.seixas@alumni.usp.br"
#
# START GEE API ---------------------------------------------------------------

## Initialize GEE ----
ee_Initialize(email = gee_email, drive = TRUE)

