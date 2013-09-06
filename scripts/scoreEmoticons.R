
setwd('C:/etc/Projects/Data/_Ongoing/EmoticonSentiment/')


#####################################################
##Part 0: Acquire Bundle of tweets with emoticons####

tweets <-  readLines("data/tweetswithemoticons.txt")
	#a vector of characterstrings, each element correpsonding to the text part of exactly one tweet


#######################################
######## Part 1: Score Tweets #########

sentiment.file <- "data/AFINN-111.txt"

#Initialize sentiment dictionary
df.sentiments <- read.table(sentiment.file,header=F,sep="\t",quote="",col.names=c("term","score"))
df.sentiments$term <- gsub("[^[:alnum:]]", " ",df.sentiments$term)

ScoreTerm <- function(term){
	df.sentiments[match(term,df.sentiments[,"term"]),"score"]
}

ScoreText <- function(text){
	text <- tolower(gsub("[^[:alnum:]]", " ",text))
	
	text <- do.call(c,strsplit(text," "))
	text <- text[text!=""]
	length(text)
	scores <- ScoreTerm(text)
	scores[is.na(scores)] <- 0
	sum(scores)
}

tweet.scores <- sapply(tweets,ScoreText)


#######################################
#### Part 2: Extract the Emoticon(s) ####

emoticon.list=c("\\:\\-\\)",
				"\\:\\-\\(",
				"\\:\\)",
				"\\:\\("
				)

## oh, oh, oh! Take care that none is a substring of another. 
## You can't have ":)" and ":))"; or ">:-)" and ":-)", etc.
## The second kind may actually be a concern
## If you do want them, you'll need to change the matching code somewhat to make sure it only matches the longest one or something

## What about emopticons that lead onto each other? Like ":->" + ">:-)" = ":->:-)"
## That's a problem too

## However, it's perfectly okay to have multiple emoticons in the same text. Like "Oh my! :-) :-O"

FindMatches <- function(emoticon,tweets){
	#This is a simple function, but I'm separating this out because I might want to replace it with a more complex logic that takes care of substrings, etc.
	grep(emoticon,tweets)
	#This will return a vector of elements from 'tweets', which contain 'emoticon'
}

emoticon.score.distributions <-
	sapply(emoticon.list, function(e){
		containing.indices <- FindMatches(e,tweets)
		score.dist <- tweet.scores[containing.indices]
		as.numeric(score.dist)
	})




###############################################
##### Part 4: Post-processing The results #####


## 1: Mean,sd
sapply(emoticon.score.distributions,mean)
sapply(emoticon.score.distributions,sd)

## 2: ???


#####################################
#To Do (2013-09-05):
#
## Make more comprehensive emoticon list
## Decide how to handle the substring cases
## If you can think of any other ways to statistically analyze/plot the distributions, add those
##########################################


