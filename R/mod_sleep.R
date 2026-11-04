sleepUI <- function(id, members, date_range) {
  
  ns <- NS(id)
  
  layout_sidebar(
    
    #Sidebar filters
    sidebar = sidebar(
      
      selectInput(
        ns("members"),
        "Group members",
        choices = members,
        selected = members,
        multiple = TRUE
      ),
      
      dateRangeInput(
        ns("dates"),
        "Date range",
        start = date_range[1],
        end = date_range[2],
        min = date_range[1],
        max = date_range[2]
      ),
      
      selectInput(
        ns("sort_by"),
        "Rank leaderboard by",
        choices = SLEEP_METRICS
      )
    ),
    
    #Dashboard layout
    layout_columns(
      
      col_widths = c(12, 6, 6, 12),
      
      #Leaderboard
      card(
        full_screen = TRUE,
        card_header("Sleep leaderboard"),
        plotlyOutput(ns("lb_plot")),
        DTOutput(ns("lb_table"))
      ),
      
      # Sleep goal progress
      card(
        full_screen = TRUE,
        card_header("Progress towards 8 hours of sleep"),
        plotlyOutput(ns("goal_plot"))
      ),
      
      # Weekly sleep patterns
      card(
        full_screen = TRUE,
        card_header("Weekly sleep patterns"),
        plotlyOutput(ns("weeks_plot"))
      ),
      
      # Raw data
      card(
        full_screen = TRUE,
        card_header("Raw data"),
        DTOutput(ns("raw_table"))
      )
    )
  )
}



sleepServer <- function(id, sleep) {
  moduleServer(id, function(input, output, session) {
    
    # 1. Filter sleep data
    filtered <- reactive({
      
      validate(need(
        length(input$members) > 0,
        "Select at least one group member."
      ))
      
      filter_sleep(
        sleep,
        input$members,
        input$dates
      )
    })
    
    
    # 2. Calculate leaderboard
    lb <- reactive({
      
      out <- sleep_leaderboard(
        filtered(),
        input$sort_by
      )
      
      validate(need(
        nrow(out) > 0,
        "No sleep data available for this selection."
      ))
      
      out
    })
    
    
    # 3. Leaderboard chart
    output$lb_plot <- renderPlotly({
      
      d <- lb()
      
      label <- names(SLEEP_METRICS)[
        SLEEP_METRICS == input$sort_by
      ]
      
      plot_ly(
        d,
        x = d[[input$sort_by]],
        y = factor(d$Id, levels = rev(d$Id)),
        type = "bar",
        orientation = "h"
      ) %>%
        layout(
          xaxis = list(title = label),
          yaxis = list(title = "")
        )
    })
    
    
    # 4. Leaderboard table
    output$lb_table <- renderDT({
      
      data_table(
        lb(),
        colnames = c(
          "Rank",
          "Member",
          "Nights tracked",
          "Average sleep (hours)",
          "Average time in bed (hours)",
          "Sleep efficiency (%)"
        )
      ) %>%
        formatRound(4:6, 2)
    })
    
    
    # Raw data table
    output$raw_table <- renderDT({
      
      d <- filtered()
      
      validate(need(
        nrow(d) > 0,
        "No sleep data available for this selection."
      ))
      
      data_table(d) %>%
        formatRound(c("sleep_hours", "time_in_bed_hours", "sleep_efficiency"), 2)
    })
    
    
    # 5. Progress towards 8-hour sleep goal
    output$goal_plot <- renderPlotly({
      
      d <- sleep_goal_progress(filtered())
      
      validate(need(
        nrow(d) > 0,
        "No sleep data available for this selection."
      ))
      
      plot_ly(
        d,
        x = ~goal_pct,
        y = ~reorder(Id, goal_pct),
        type = "bar",
        orientation = "h",
        text = ~paste0(
          round(avg_sleep, 1),
          " average hours; ",
          nights_met,
          " of ",
          nights,
          " nights meeting target"
        ),
        hoverinfo = "text"
      ) %>%
        layout(
          xaxis = list(
            title = "% of nights achieving 8 hours"
          ),
          yaxis = list(title = ""),
          shapes = list(
            list(
              type = "line",
              x0 = 100,
              x1 = 100,
              y0 = 0,
              y1 = 1,
              yref = "paper",
              line = list(dash = "dash")
            )
          )
        )
    })
    
    
    # 6. Weekly sleep patterns
    output$weeks_plot <- renderPlotly({
      
      d <- weekly_sleep_summary(filtered())
      
      validate(need(
        nrow(d) > 0,
        "No sleep data available for this selection."
      ))
      
      plot_ly(
        d,
        x = ~week,
        y = ~avg_sleep,
        color = ~Id,
        type = "scatter",
        mode = "lines+markers"
      ) %>%
        layout(
          xaxis = list(title = "Week starting"),
          yaxis = list(title = "Average sleep (hours)"),
          shapes = list(
            list(
              type = "line",
              y0 = 8,
              y1 = 8,
              x0 = 0,
              x1 = 1,
              xref = "paper",
              line = list(dash = "dash")
            )
          )
        )
    })
    
  })
}
