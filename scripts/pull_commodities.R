# -------------------------------------------------------------------
# pull_commodities.R
# Script to download raw commodity futures data from Yahoo Finance
# and save it to data/raw/ for reproducible EDAV project workflow.
# -------------------------------------------------------------------

library(tidyverse)
library(tidyquant)
library(janitor)

# -----------------------------
# 1. Parameters
# -----------------------------
tickers <- c("GC=F", "CL=F", "NG=F")   # gold, WTI crude oil, natural gas
start_date <- "2014-01-01"
end_date   <- Sys.Date()

# -----------------------------
# 2. Download data
# -----------------------------
commod_raw <- tq_get(
  tickers,
  from = start_date,
  to   = end_date,
  get  = "stock.prices"
) |>
  clean_names() |>              # standardized snake_case column names
  rename(
    ticker = symbol,
    price  = adjusted
  )

# -----------------------------
# 3. Add returns
# -----------------------------
commod_raw <- commod_raw |>
  group_by(ticker) |>
  arrange(date, .by_group = TRUE) |>
  mutate(
    ret_simple = price / lag(price) - 1,
    ret_log    = log(price / lag(price))
  ) |>
  ungroup()

# -----------------------------
# 4. Save data to data/raw/
# -----------------------------
# Create folder if it doesn't exist
if (!dir.exists("data/raw")) {
  dir.create("data/raw", recursive = TRUE)
}

write_rds(commod_raw, "data/raw/commodities_raw.rds")
write_csv(commod_raw, "data/raw/commodities_raw.csv")

# -----------------------------
# 5. Message for user
# -----------------------------
message("Commodity data successfully saved to data/raw/")

