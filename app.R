# Load packages
library(shiny)
library(bslib) 
library(shinymanager)
library(plotly)
library(DT)

source("R/calc_overview.R")
source("R/mod_overview.R")

data_dir <- Sys.getenv("FITBIT_DATA_DIR", "data-raw")
daily <- load_daily_activity(data_dir)

# Create UI and wrap using shinymanager for login
ui <- page_navbar(
  title = "Fitbit Group Dashboard",
  nav_panel("Overview", overviewUI("overview", sort(unique(daily$Id)), range(daily$Date)))
  # nav_panel("Training", trainingUI("training")),
  # nav_panel("Workouts", workoutsUI("workouts")),
  # nav_panel("Heartrate", heartrateUI("heartrate")),
  # nav_panel("Sleep", sleepUI("sleep")),
  # nav_panel("Coverage", coverageUI("coverage"))
)
ui <- secure_app(ui, timeout = 15)

# Create server
server <- function(input, output, session) {
  # Read credentials for login
  secure_server(check_credentials = check_credentials("www/credentials.sqlite"))
#   
  overviewServer("overview", daily)
  # sleepServer()
}

shinyApp(ui, server)
