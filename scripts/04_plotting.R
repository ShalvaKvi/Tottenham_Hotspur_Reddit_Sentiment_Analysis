library(tidyverse)
library(plotly)

threads <- read_csv('./data/threads.csv')
results <- read_csv('./data/results.csv')

threads <- threads |> 
  arrange(date) |> 
  left_join(results, by= 'date')


ggplot(data = threads) +
  geom_line(aes(x = date, y = mean_sentiment)) +
  geom_point(aes(x = date, y= 0.1, group = factor(win), color = factor(win)), size = 5)
