source(file.path("..", "..", "R", "calc_overview.R"))
source(file.path("..", "..", "R", "calc_intensity.R"))

make_days <- function() {
  data.frame(
    Id = c("A", "A", "A", "B"),
    Date = as.Date("2016-04-18") + c(0, 1, 2, 0),
    TotalSteps = c(8000, 4000, 0, 6000),
    SedentaryMinutes = c(600, 800, 1440, 700),
    LightlyActiveMinutes = c(200, 100, 0, 150),
    FairlyActiveMinutes = c(20, 10, 0, 0),
    VeryActiveMinutes = c(40, 20, 0, 30)
  )
}

test_that("intensity_breakdown averages each level per member", {
  out <- intensity_breakdown(make_days())
  a <- out[out$Id == "A", ]
  expect_equal(a$avg_minutes, c(700, 150, 15, 30))
})

test_that("intensity_breakdown excludes zero-step days", {
  out <- intensity_breakdown(make_days())
  expect_equal(unique(out$days[out$Id == "A"]), 2)
})

test_that("intensity_breakdown returns the four levels in order", {
  out <- intensity_breakdown(make_days())
  expect_equal(as.character(out$level[out$Id == "B"]),
               c("Sedentary", "Light", "Fair", "Very active"))
})

test_that("shares add up to 100 for each member", {
  out <- intensity_breakdown(make_days())
  expect_equal(as.numeric(tapply(out$share, out$Id, sum)), c(100, 100))
})

test_that("a member with only zero-step days is left out", {
  out <- intensity_breakdown(make_days()[3, ])
  expect_equal(nrow(out), 0)
})
