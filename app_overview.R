# Standalone app for the Overview page, until the team skeleton (app.R) exists.
# Run from the repo root:  shiny::runApp("app_overview.R")
# Set FITBIT_DATA_DIR to the folder containing the Fitbit CSVs, or copy them into data-raw/.

library(shiny)
library(bslib)
library(plotly)
library(DT)

source("R/calc_overview.R")
source("R/mod_overview.R")

data_dir <- Sys.getenv("FITBIT_DATA_DIR", "data-raw")
daily <- load_daily_activity(data_dir)

ui <- page_navbar(
  title = "Fitbit Group Dashboard",
  nav_panel("Overview", overviewUI("overview", sort(unique(daily$Id)), range(daily$Date)))
)

server <- function(input, output, session) {
  overviewServer("overview", daily)
}

shinyApp(ui, server)
