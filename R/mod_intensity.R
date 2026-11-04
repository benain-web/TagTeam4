intensityUI <- function(id, members, dates) {
  ns <- NS(id)
  section_page(
    ns, members, dates,
    viz_card("Average day by activity intensity", plotlyOutput(ns("breakdown_plot"))),
    viz_card("Raw data", DTOutput(ns("raw_table")))
  )
}

intensityServer <- function(id, df) {
  moduleServer(id, function(input, output, session) {
    filtered <- reactive(filter_daily(df, input$members, input$dates))

    output$breakdown_plot <- renderPlotly({
      d <- require_rows(intensity_breakdown(filtered()))
      plot_ly(d, x = ~avg_minutes, y = ~Id, color = ~level,
              type = "bar", orientation = "h",
              text = ~paste0(level, ": ", round(avg_minutes), " min per day (",
                             round(share, 1), "%), ", days, " days tracked"),
              hoverinfo = "text", textposition = "none") %>%
        layout(barmode = "stack",
               xaxis = list(title = "Average minutes per day"),
               yaxis = list(title = "", type = "category"))
    })

    output$raw_table <- renderDT(data_table(require_rows(filtered())))
  })
}
