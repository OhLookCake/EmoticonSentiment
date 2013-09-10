Emoticon Sentiments
===================

The script gatherTweets.py reads from Twitter's streaming API, and writes any tweet with an emoticon in it to a file.
The R script scoreEmoticons.R then reads this file, scores each tweet, and searches for the presence of each emoticon (from a predefined list). The score distributions for each emoticon are then plotted.

A more descriptive analysis can be found on my blog [Hot Damn, Data!](http://www.hotdamndata.com/2013/09/the-happiest-emoticons.html) -- The Happiest Emoticons