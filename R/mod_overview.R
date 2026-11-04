overviewUI <- function(id, members, dates) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      selectInput(ns("members"), "Group members", members, members, multiple = TRUE),
      dateRangeInput(ns("dates"), "Date range", dates[1], dates[2], dates[1], dates[2]),
      selectInput(ns("sort_by"), "Rank leaderboard by", OVERVIEW_METRICS)
    ),
    layout_columns(
      col_widths = c(12, 6, 6, 12),
      card(full_screen = TRUE, card_header("Leaderboard"),
           plotlyOutput(ns("lb_plot")), DTOutput(ns("lb_table"))),
      card(full_screen = TRUE, card_header("Progress towards 10,000 daily steps"),
           plotlyOutput(ns("goal_plot"))),
      card(full_screen = TRUE, card_header("Weeks meeting 150 active minutes"),
           plotlyOutput(ns("weeks_plot"))),
      card(full_screen = TRUE, card_header("Raw data"), DTOutput(ns("raw_table")))
    )
  )
}

overviewServer <- function(id, daily) {
  moduleServer(id, function(input, output, session) {
    filtered <- reactive({
      validate(need(input$members, "Select at least one group member."))
      filter_daily(daily, input$members, input$dates)
    })

    lb <- reactive({
      d <- leaderboard(filtered(), input$sort_by)
      validate(need(nrow(d) > 0, "No activity data for this selection."))
      d
    })

    output$lb_plot <- renderPlotly({
      d <- lb()
      plot_ly(x = d[[input$sort_by]], y = factor(d$Id, rev(d$Id)),
              type = "bar", orientation = "h") %>%
        layout(xaxis = list(title = names(which(OVERVIEW_METRICS == input$sort_by))),
               yaxis = list(title = ""))
    })

    output$lb_table <- renderDT(data_table(lb(), colnames = c(
      "Rank", "Member", "Days", "Avg steps", "Avg distance (km)",
      "Avg active mins", "Avg calories")))

    output$raw_table <- renderDT({
      d <- filtered()
      validate(need(nrow(d) > 0, "No activity data for this selection."))
      data_table(d)
    })

    output$goal_plot <- renderPlotly({
      d <- step_goal_progress(filtered())
      validate(need(nrow(d) > 0, "No step data for this selection."))
      plot_ly(d, x = ~goal_pct, y = factor(d$Id, rev(d$Id)), type = "bar", orientation = "h",
              text = ~paste(avg_steps, "avg steps, goal hit on", days_met, "of", days, "days"),
              hoverinfo = "text") %>%
        layout(xaxis = list(title = "% of 10,000 step goal"), yaxis = list(title = ""))
    })

    output$weeks_plot <- renderPlotly({
      d <- weekly_target_summary(filtered())
      validate(need(nrow(d) > 0, "No complete weeks in this selection."))
      plot_ly(d, y = factor(d$Id, rev(d$Id)), x = ~weeks_tracked, type = "bar",
              orientation = "h", name = "Weeks tracked", marker = list(color = "lightgrey")) %>%
        add_trace(x = ~weeks_met, name = "Target met", marker = list(color = "seagreen")) %>%
        layout(barmode = "overlay", xaxis = list(title = "Weeks", dtick = 1),
               yaxis = list(title = ""))
    })
  })
}
