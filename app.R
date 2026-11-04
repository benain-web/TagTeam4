# Load packages
library(shiny)
library(bslib) 
library(shinymanager)
library(plotly)
library(DT)

source("R/ui_helpers.R")
source("R/calc_overview.R")
source("R/mod_overview.R")
source("R/calc_sleep.R")
source("R/mod_sleep.R")
source("R/mod_heartrate.R")
source("R/calc_intensity.R")
source("R/mod_intensity.R")

data_dir <- Sys.getenv("FITBIT_DATA_DIR", "data-raw")
daily <- load_daily_activity(data_dir)
intensity <- load_intensity(data_dir)

sleep <- read.csv(file.path(data_dir, "sleepDay_merged.csv"), stringsAsFactors = FALSE)
sleep <- prepare_sleep(sleep)

# Create UI and wrap using shinymanager for login
ui <- page_navbar(
  title = "Fitbit Group Dashboard",
  nav_panel("Overview", overviewUI("overview", sort(unique(daily$Id)), range(daily$Date))),
  nav_panel("Heartrate", heartrateUI("heartrate")),
  nav_panel("Sleep", sleepUI("sleep", sort(unique(sleep$Id)),range(sleep$SleepDay))),
  nav_panel("Intensity", intensityUI("intensity", sort(unique(intensity$Id)), range(intensity$Date)))
)
ui <- secure_app(ui, timeout = 15)

# Create server
server <- function(input, output, session) {
  # Read credentials for login
  secure_server(check_credentials = check_credentials("www/credentials.sqlite"))
 
  overviewServer("overview", daily)
  sleepServer("sleep", sleep)
  heartrateServer("heartrate")
  intensityServer("intensity", intensity)
}

shinyApp(ui, server)
