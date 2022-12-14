library(tidyverse)
library(rvest)

# Fetch results from worldfootball.net
results <-
  read_html('https://www.worldfootball.net/teams/tottenham-hotspur/2022/3/') |>
  html_nodes(
    ".dunkel:nth-child(7) , .hell:nth-child(7) , .portfolio .dunkel:nth-child(2) a ,
             .portfolio .hell:nth-child(2) , .dunkel:nth-child(6) , .hell:nth-child(6)"
  ) |>
  html_text()

# Convert to a data.frame
results <-
  matrix(results,
         ncol = 3,
         nrow = length(results) / 3,
         byrow = TRUE) |>
  as.data.frame()

# Wrangling the results a bit --- renaming columns, adjusting features, etc.
results <- results |>
  rename("date" = "V1",
         "opponent" = "V2",
         "score" = "V3") |>
  mutate(
    opponent = str_replace_all(string = opponent, pattern = "\n",replacement = ""),
    date = as.POSIXlt(date, format = "%d/%m/%Y"),
    score = str_extract(string = score, pattern = "[:digit:]:[:digit:]"),
    score_tot = as.numeric(str_extract(string = score, pattern = "^[:digit:]")),
    score_op = as.numeric(str_extract(string = score, pattern = "[:digit:]$")),
    win = case_when(
      score_tot > score_op ~ 1,
      score_tot < score_op ~ 0,
      score_tot == score_op ~ 0.5
    )
  )

# Write csv
write_csv(x = results, file = "./data/results.csv")
