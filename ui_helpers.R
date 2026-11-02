library(shiny)
library(bslib)
library(plotly)
library(DT)

# Chart card that can be maximised and closed (REQ-08, REQ-09). Plotly adds PNG download (REQ-10).
viz_card <- function(title, output) {
  card(full_screen = TRUE, card_header(title), output)
}

# Raw data table with filtering, sorting and CSV download (REQ-16 to REQ-18)
data_table <- function(df) {
  datatable(df, rownames = FALSE, filter = "top", extensions = "Buttons",
            options = list(dom = "Bfrtip", buttons = list("csv"), pageLength = 10))
}

# Standard page: member and date filters on the left, content on the right (REQ-11, REQ-12).
# Extra sidebar inputs can be passed as a list in sidebar_extra.
section_page <- function(ns, members, dates, ..., sidebar_extra = NULL) {
  layout_sidebar(
    sidebar = sidebar(
      selectInput(ns("members"), "Group members", members, members, multiple = TRUE),
      dateRangeInput(ns("dates"), "Date range", dates[1], dates[2], dates[1], dates[2]),
      sidebar_extra
    ),
    ...
  )
}

# Shows a message instead of an empty chart (REQ-14)
require_rows <- function(df, msg = "No data available for this selection.") {
  validate(need(nrow(df) > 0, msg))
  df
}
