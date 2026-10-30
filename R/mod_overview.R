# Overview page Shiny module (Person 1: REQ-19, REQ-20, REQ-21)

overviewUI <- function(id, members, date_range) {
  ns <- NS(id)
  layout_sidebar(
    sidebar = sidebar(
      selectInput(ns("members"), "Group members", choices = members,
                  selected = members, multiple = TRUE),
      dateRangeInput(ns("dates"), "Date range",
                     start = date_range[1], end = date_range[2],
                     min = date_range[1], max = date_range[2]),
      selectInput(ns("sort_by"), "Rank leaderboard by", choices = OVERVIEW_METRICS)
    ),
    layout_columns(
      col_widths = c(12, 6, 6),
      card(
        full_screen = TRUE,
        card_header("Leaderboard"),
        plotlyOutput(ns("lb_plot")),
        DTOutput(ns("lb_table"))
      ),
      card(
        full_screen = TRUE,
        card_header("Progress towards 10,000 daily steps"),
        plotlyOutput(ns("goal_plot"))
      ),
      card(
        full_screen = TRUE,
        card_header("Weeks meeting 150 active minutes"),
        plotlyOutput(ns("weeks_plot"))
      )
    )
  )
}

overviewServer <- function(id, daily) {
  moduleServer(id, function(input, output, session) {
    
    filtered <- reactive({
      validate(need(length(input$members) > 0, "Select at least one group member."))
      filter_daily(daily, input$members, input$dates)
    })
    
    lb <- reactive({
      out <- leaderboard(filtered(), input$sort_by)
      validate(need(nrow(out) > 0, "No activity data available for this selection."))
      out
    })
    
    output$lb_plot <- renderPlotly({
      d <- lb()
      label <- names(OVERVIEW_METRICS)[OVERVIEW_METRICS == input$sort_by]
      plot_ly(d, x = d[[input$sort_by]], y = factor(d$Id, levels = rev(d$Id)),
              type = "bar", orientation = "h") %>%
        layout(xaxis = list(title = label), yaxis = list(title = ""))
    })
    
    output$lb_table <- renderDT({
      datatable(
        lb(),
        rownames = FALSE,
        colnames = c("Rank", "Member", "Days tracked", "Avg steps",
                     "Avg distance (km)", "Avg active mins", "Avg calories"),
        options = list(pageLength = 10)
      )
    })
    
    output$goal_plot <- renderPlotly({
      d <- step_goal_progress(filtered())
      validate(need(nrow(d) > 0, "No step data available for this selection."))
      plot_ly(d, x = ~goal_pct, y = factor(d$Id, levels = rev(d$Id)),
              type = "bar", orientation = "h",
              text = ~paste0(avg_steps, " avg steps, goal hit on ",
                             days_met, " of ", days, " days"),
              hoverinfo = "text") %>%
        layout(
          xaxis = list(title = "% of 10,000 step goal (daily average)"),
          yaxis = list(title = ""),
          shapes = list(list(type = "line", x0 = 100, x1 = 100, y0 = 0, y1 = 1,
                             yref = "paper", line = list(dash = "dash")))
        )
    })
    
    output$weeks_plot <- renderPlotly({
      d <- weekly_target_summary(filtered())
      validate(need(nrow(d) > 0, "No complete Monday-Sunday weeks in this selection."))
      y <- factor(d$Id, levels = rev(d$Id))
      plot_ly(d, y = y, x = ~weeks_tracked, type = "bar", orientation = "h",
              name = "Complete weeks tracked", marker = list(color = "lightgrey")) %>%
        add_trace(x = ~weeks_met, name = "Weeks target met",
                  marker = list(color = "seagreen")) %>%
        layout(barmode = "overlay", xaxis = list(title = "Weeks", dtick = 1),
               yaxis = list(title = ""))
    })
  })
}