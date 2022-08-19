![spurs_logo_250x250](https://user-images.githubusercontent.com/102624754/184536016-12c8446b-14a7-46c5-ae71-8b3c5b763a88.jpg)

## What is this?
I've been a huge fan of the Tottenham Hotspur Football Club (THFC) of the Premier League for some time now. One of the main platforms that I use to connect with other fans is the dedicated fan subreddit [r/coys](https://www.reddit.com/r/coys/). A cool thing about the subreddit is that every match the club plays has an oragnized match thread that fans can discuss ongoing matches, and post-match threads, where fans can discuss concluded matches. Because the discussion is so neatly organized in the subreddit, we can easily utilize NLP techniques to analyze those threads and gain some valuable insights! 

### *The following questions peaked my interest the most:*
 1. Can we identify different sentiment patterns for matches where the club won or lost?
 2. How does the sentiment differ in match threads as opposed to post-match threads?
 3. Does the match outcome has a lasting effect on the general sentiment of the subrredit? 

## How did I go about it?
I thought it would be cool to tackle these questions by building an interactive application that will allow the user to freely explore the data! These are the steps that I took:
 1. I web-scraped match results from the 2021-2022 season from the web using the *rvest* library (see: ['/scripts/01_match_information.R'](https://github.com/ShalvaKvi/Tottenham_Hotspur_Reddit_Sentiment_Analysis/blob/main/scripts/01_match_information.R)).
 2. Then, I used Reddit's API to retrieve all the match\post-match\daily discussion threads that I could find (see: ['/scripts/02_reddit_thread_data_retrieval.R'](https://github.com/ShalvaKvi/Tottenham_Hotspur_Reddit_Sentiment_Analysis/blob/main/scripts/02_reddit_threads_data_retrieval.R)).
 3. After putting everything together, I conducted the sentiment analysis with the excellent *sentimentr* library (see: ['/scripts/03_sentiment_analysis.R'](https://github.com/ShalvaKvi/Tottenham_Hotspur_Reddit_Sentiment_Analysis/blob/main/scripts/03_sentiment_analysis.R)).
 4. And Finally, I built an interactive dashboard with *flexdashboard* and *plotly* (see: ['/dashboard/dashboard.Rmd'](https://github.com/ShalvaKvi/Tottenham_Hotspur_Reddit_Sentiment_Analysis/blob/main/dashboard/dashboard.Rmd)).

