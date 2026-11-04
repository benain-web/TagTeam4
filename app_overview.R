# Set FITBIT_DATA_DIR to the Fitbit CSV folder, then run shiny::runApp("app_overview.R")
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
