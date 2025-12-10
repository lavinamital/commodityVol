
library(tidyverse)
library(tidyquant)
library(janitor)


tickers <- c("GC=F", "CL=F", "NG=F")
start_date <- "2014-01-01"
end_date   <- Sys.Date()


commod_raw <- tq_get(
  tickers,
  from = start_date,
  to   = end_date,
  get  = "stock.prices"
) |>
  clean_names() |>
  rename(
    ticker = symbol,
    price  = adjusted
  )

commod_raw <- commod_raw |>
  group_by(ticker) |>
  arrange(date, .by_group = TRUE) |>
  mutate(
    ret_simple = price / lag(price) - 1,
    ret_log    = log(price / lag(price))
  ) |>
  ungroup()


if (!dir.exists("data/raw")) {
  dir.create("data/raw", recursive = TRUE)
}

write_rds(commod_raw, "data/raw/commodities_raw.rds")
write_csv(commod_raw, "data/raw/commodities_raw.csv")

message("Commodity data successfully saved to data/raw/")

