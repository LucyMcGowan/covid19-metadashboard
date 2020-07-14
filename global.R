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
library(mongolite)

options(
  gargle_oauth_cache = ".secrets",
  gargle_oauth_email = "lucydagostino@gmail.com"
)
source("sheets_ids.R")

gs4_deauth()

databaseName <- "ratings"
collectionName <- "responses"

save_data <- function(data) {
  db <- mongo(collection = collectionName,
              url = 
                glue("mongodb+srv://{options()$mongo$username}:{options()$mongodb$password}@{options()$mongodb$host}/{databaseName}?retryWrites=true&w=majority")
               )
  db$insert(data)
}

load_data <- function() {
  db <- mongo(collection = collectionName,
              url = 
                glue("mongodb+srv://{options()$mongo$username}:{options()$mongodb$password}@{options()$mongodb$host}/{databaseName}?retryWrites=true&w=majority")
  )
  data <- db$find()
  data
}

update_data <- function(query, update) {
  db <- mongo(collection = collectionName,
              url = 
                glue("mongodb+srv://{options()$mongo$username}:{options()$mongodb$password}@{options()$mongodb$host}/{databaseName}?retryWrites=true&w=majority")
  )
  db$update(query, update)
}

