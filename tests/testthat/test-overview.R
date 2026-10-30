source(file.path("..", "..", "R", "calc_overview.R"))

make_daily <- function() {
  dates <- seq(as.Date("2016-04-18"), as.Date("2016-05-01"), by = "day")
  rbind(
    data.frame(Id = "A", Date = dates, TotalSteps = 12000, TotalDistance = 9,
               ActiveMinutes = 30, Calories = 2500),
    data.frame(Id = "B", Date = dates, TotalSteps = c(rep(5000, 13), 0),
               TotalDistance = 3.5, ActiveMinutes = 10, Calories = 1900)
  )
}

test_that("leaderboard ranks members by the chosen metric", {
  lb <- leaderboard(make_daily(), "avg_steps")
  expect_equal(lb$Id, c("A", "B"))
  expect_equal(lb$rank, c(1, 2))
  expect_equal(lb$avg_steps, c(12000, 5000))
})

test_that("leaderboard excludes zero-step days", {
  lb <- leaderboard(make_daily())
  expect_equal(lb$days[lb$Id == "B"], 13)
})

test_that("leaderboard rejects unknown metrics", {
  expect_error(leaderboard(make_daily(), "nonsense"), "Unknown metric")
})

test_that("step goal progress is a percentage of the goal", {
  sg <- step_goal_progress(make_daily(), goal = 10000)
  expect_equal(sg$goal_pct[sg$Id == "A"], 120)
  expect_equal(sg$goal_pct[sg$Id == "B"], 50)
  expect_equal(sg$days_met[sg$Id == "A"], 14)
  expect_equal(sg$days_met[sg$Id == "B"], 0)
})

test_that("weekly target counts only complete weeks", {
  df <- make_daily()
  ws <- weekly_target_summary(df, target = 150)
  expect_equal(ws$weeks_tracked, c(2, 2))
  expect_equal(ws$weeks_met[ws$Id == "A"], 2)
  expect_equal(ws$weeks_met[ws$Id == "B"], 0)
  
  partial <- df[df$Date != as.Date("2016-05-01"), ]
  expect_equal(weekly_target_summary(partial)$weeks_tracked, c(1, 1))
})

test_that("filter_daily filters by member and date", {
  df <- make_daily()
  out <- filter_daily(df, "A", as.Date(c("2016-04-18", "2016-04-20")))
  expect_equal(unique(out$Id), "A")
  expect_equal(nrow(out), 3)
  expect_equal(nrow(filter_daily(df)), nrow(df))
})