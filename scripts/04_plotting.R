library(tidyverse)
library(plotly)

threads <- read_csv('./data/thread_info.csv')
results <- read_csv('./data/results.csv')

combined_data <- threads |> 
  arrange(date) |> 
  left_join(results, by = 'date') |> 
  mutate(matchday = factor(ifelse(is.na(opponent), yes = 0, no = 1))) |> 
  fill(win)

combined_data <- combined_data |> 
  mutate(win = factor(win, levels = c(1, 0.5, 0), labels = c("Win", "Draw", "Lose")),
         score_label = paste('Tottenham Hotspur', score.y, opponent),
         mean_sentiment = round(mean_sentiment, digits = 5),
         polarity = round(polarity, digits = 5))

write_rds(combined_data, './dashboard/combined_data.rds')




plt <- combined_data |> 
  filter(thread_type == "daily") |> 
  
  ggplot(aes(x = date, y = mean_sentiment, text = ifelse(matchday == 1, 
                                                         paste0('Date: ', date, '\n', 
                                                         'Match: ',score_label, '\n', 
                                                         'Sentiment: '),
                                                         paste0('Date: ', date)))) +
  
  geom_smooth(span = 0.1, se = F, size = 1, color = "grey60") +
  
  geom_segment(aes(yend = 0, xend = date, color = win, size = matchday),
               lineend = "round") +
  
  scale_color_manual(values = c("#0072B5", "#20854E", "#BC3C29")) +
  scale_size_manual(values = c(0.2, 1.5))
  # geom_line(alpha = 0.2, size = 1) +

ggplotly(plt, tooltip = 'text') %>%
  layout(legend = list(orientation = 'h'))



  geom_hline(yintercept = 0) +
  geom_segment(aes(yend = 0, xend = date, color = win),
               lineend = "round",
               size = 2) +
  geom_point(aes(y = mean_sentiment, color = win),
             size = 4) +
  