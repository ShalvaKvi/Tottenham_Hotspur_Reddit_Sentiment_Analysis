pacman::p_load(tidyverse, RedditExtractoR, wordcloud2, rvest)


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



# Fetch Reddit thread urls and convert date to POSIxlt
urls <-
  find_thread_urls(keywords = "Post-match thread",
                   subreddit = "coys",
                   period = "year") |>
  mutate(date_utc = as.POSIXlt(date_utc, format = "%Y-%m-%d")) |>
  filter(str_detect(title, pattern = 'Post') == TRUE) |> 
  select(date_utc, title, comments, url)


# Join togther
results <- results |>
  left_join(urls, by = c("date" = "date_utc")) |>
  filter(!is.na(url)) |>
  arrange(desc(date))

results <- results[-c(50, 49),] # Friendly games


# Export

write.csv(results, "results.csv",row.names = FALSE)


# Fetch comments from the threads


link <- results$url


comments <- get_thread_content(link)


threads <- comments$threads
comments <- comments$comments



# assign gameid to all data frames
results <- results |> 
  mutate(gameid = 1:n())

threads <- threads |> 
  left_join(results |> select(gameid, url), by = c("url" = "url"))

comments <- comments |> 
  left_join(results |> select(gameid, url), by = c("url" = "url"))


write.csv(threads, "threads.csv",row.names = FALSE)
write.csv(comments, "comments.csv",row.names = FALSE)
write.csv(results, "results.csv",row.names = FALSE)
