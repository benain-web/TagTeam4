# Copy this file to R/mod_<section>.R and rename "template" to your section.
# Your data needs Id and Date columns. Put calculations in R/calc_<section>.R so they can be tested.

templateUI <- function(id, members, dates) {
  ns <- NS(id)
  section_page(
    ns, members, dates,
    layout_columns(
      col_widths = c(6, 6, 12),
      viz_card("Chart 1", plotlyOutput(ns("chart1"))),
      viz_card("Chart 2", plotlyOutput(ns("chart2"))),
      viz_card("Raw data", DTOutput(ns("table")))
    )
  )
}

templateServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    filtered <- reactive({
      validate(need(input$members, "Select at least one group member."))
      data %>%
        filter(Id %in% input$members, between(Date, input$dates[1], input$dates[2])) %>%
        require_rows()
    })

    output$chart1 <- renderPlotly({
      d <- filtered() %>% group_by(Id) %>% summarise(value = mean(value))
      plot_ly(d, x = ~Id, y = ~value, type = "bar")
    })

    output$chart2 <- renderPlotly({
      plot_ly(filtered(), x = ~Date, y = ~value, color = ~Id, type = "scatter", mode = "lines")
    })

    output$table <- renderDT(data_table(filtered()))
  })
}

# Try the template on its own with dummy data:
#   source("R/ui_helpers.R"); source("R/mod_template.R"); library(dplyr)
#   d <- expand.grid(Id = c("A", "B"), Date = Sys.Date() - 0:9); d$value <- runif(20)
#   shinyApp(page_navbar(nav_panel("Test", templateUI("t", c("A", "B"), range(d$Date)))),
#            function(input, output, session) templateServer("t", d))
