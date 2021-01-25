# HEADER ----------------------------------------------------------------------
#
# Title:        
# Description:  
#
# Authors:      Hugo Tameirao Seixas, Marcelo Bandoria
# Contact:      tameirao.hugo@gmail.com, marcelobandoria@gmail.com
# Date:         2021-25-01
#
# Notes:        
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

