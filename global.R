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

options(
  gargle_oauth_cache = ".secrets",
  gargle_oauth_email = "lucydagostino@gmail.com"
)
source("sheets_ids.R")

gs4_deauth()