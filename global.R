library(shiny)
library(purrr)
library(yaml)
library(tidyverse)
library(DT)
library(shinyjs)
library(glue)
library(shinydashboard)
library(googlesheets4)
library(googledrive)

source("sheets_ids.R")

options(
  gargle_oauth_cache = ".secrets",
  gargle_oauth_email = TRUE
)

gs4_deauth()
