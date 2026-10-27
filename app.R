# Load packages
library(shiny)
library(bslib) 
library(shinymanager)

# Create UI and wrap using shinymanager for login
ui <- page_navbar(
  title = "Fitbit Group Dashboard",
  nav_panel("Overview", overviewUI("overview")),
  nav_panel("Training", trainingUI("training")),
  nav_panel("Workouts", workoutsUI("workouts")),
  nav_panel("Heartrate", heartrateUI("heartrate")),
  nav_panel("Sleep", sleepUI("sleep")),
  nav_panel("Coverage", coverageUI("coverage"))
)
ui <- secure_app(ui, timeout = 15)

# Create server
server <- function(input, output, session) {
  # Read credentials for login
  secure_server(check_credentials = check_credentials("www/credentials.sqlite"))
  
  overviewServer()
  sleepServer()
}

shinyApp(ui, server)
