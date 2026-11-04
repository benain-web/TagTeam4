
# ======================================
# CREATE ANALYSIS PAGE
# ======================================

library(data.table)

#Read heart rate dataset
raw_data <- fread("data-raw/heartrate_seconds_merged.csv",colClasses = c(Id = "character"))

#Convert Time to a proper date
raw_data[, Date := as.Date(as.POSIXct(Time,format = "%m/%d/%Y %I:%M:%S %p",tz = "UTC"))]

#Calculate daily average heart rate
d <- raw_data[!is.na(Date) & !is.na(Value),.(value = mean(Value, na.rm = TRUE)),by = .(Id, Date)]

#Convert to data frame
d <- as.data.frame(d)

#Analysis ui layout

heartrateUI <- function(id, members = unique(d$Id), dates = range(d$Date)) {
  ns <- NS(id)
  
  section_page(
    ns, members, dates,
    
    layout_columns(
      col_widths = c(6, 6, 12),
      viz_card("Average Heart Rate by Person",plotlyOutput(ns("chart1"))),
      viz_card("Average Heart Rate Over Time",plotlyOutput(ns("chart2"))),
      viz_card("Heart Rate Data Table",DTOutput(ns("table"))
)))}

#create analysis server
heartrateServer <- function(id, data = d) {
  
  moduleServer(id, function(input, output, session) {
    
    filtered <- reactive({validate(need(length(input$members) > 0,"Select at least one person."))
      
    data %>%filter(Id %in% input$members,between(Date, input$dates[1], input$dates[2])) %>%require_rows()})
    
    #Chart 1-Average Heart Rate by Person
    output$chart1 <- renderPlotly({d <- filtered() %>% 
    group_by(Id) %>%
    summarise(value = mean(value, na.rm = TRUE),.groups = "drop")
    plot_ly(d, x = ~Id, y = ~value, type = "bar") %>%
    layout(xaxis = list(title = "Person ID"),yaxis = list(title = "Average Heart Rate (BPM)"))})
    
    # hart 2-Heart Rate Over Time
    output$chart2 <- renderPlotly({
    plot_ly(filtered(),x = ~Date,y = ~value,color = ~Id,type = "scatter",mode = "lines") %>%
    layout(xaxis = list(title = "Date"),yaxis = list(title = "Heart Rate (BPM)"))})
    
    #Table-Rename the displayed column
    output$table <- renderDT({filtered() %>%rename(`Heart Rate (BPM)` = value) %>%data_table()})})
  }
