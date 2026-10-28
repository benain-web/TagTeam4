suppressMessages(library(dplyr))
source(file.path("..", "..", "R", "ui_helpers.R"))
source(file.path("..", "..", "R", "mod_template.R"))

dummy <- data.frame(Id = rep(c("A", "B"), each = 3),
                    Date = rep(as.Date("2016-04-12") + 0:2, 2),
                    value = 1:6)

test_that("data_table has CSV button and filters", {
  dt <- data_table(dummy)
  expect_s3_class(dt, "datatables")
  expect_equal(dt$x$filter, "top")
  expect_true("csv" %in% unlist(dt$x$options$buttons))
})

test_that("template UI builds", {
  expect_s3_class(templateUI("t", c("A", "B"), range(dummy$Date)), "shiny.tag")
})

test_that("section_page adds extra sidebar inputs", {
  ui <- section_page(NS("t"), "A", range(dummy$Date),
                     sidebar_extra = selectInput("t-extra", "Extra", "x"))
  expect_match(as.character(ui), "t-extra")
})

test_that("template server filters by member and date", {
  testServer(templateServer, args = list(data = dummy), {
    session$setInputs(members = "A", dates = as.Date(c("2016-04-12", "2016-04-13")))
    expect_equal(nrow(filtered()), 2)
    expect_equal(unique(filtered()$Id), "A")
  })
})

test_that("template server shows a message when nothing is selected", {
  testServer(templateServer, args = list(data = dummy), {
    session$setInputs(members = character(0), dates = range(dummy$Date))
    expect_error(filtered(), "Select at least one group member")
  })
})
