
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


#########################################
#### Part 2: Extract the Emoticon(s) ####


emoticon.list <- c(	"\\:\\-\\)","\\:\\)","\\=\\)",
					"\\:\\-D","\\:D","8\\-D","8D","x\\-D","xD","X\\-D","XD",
					"\\:\\-\\(","\\:\\(",
					"\\:\\-\\|","\\:\\|",
					"\\:\\'\\-\\(","\\:\\'\\(\\)",
					"\\:\\'\\-\\)","\\:\\'\\)",
					"\\:\\-o","\\:\\-O","\\:o","\\:O",
					"o_O","o_0","o\\.O",
					"\\:\\*","\\;\\-\\)","\\;\\)",
					"\\%\\-\\)","\\%\\)",
					"\\<3","\\<\\/3" )

## oh, oh, oh! Take care that none is a substring of another. 
## You can't have ":)" and ":))"; or ">:-)" and ":-)", etc.
## The second kind may actually be a concern
## If you do want them, you'll need to change the matching code somewhat to make sure it only matches the longest one or something

## What about emoticons that lead onto each other? Like ":->" + ">:-)" = ":->:-)"
## That's a problem too

## However, it's perfectly okay to have multiple emoticons in the same text. Like "Oh my! :-) :-O"

FindMatches <- function(emoticon,tweets){
	#This is a simple function, but I'm separating this out because I might want to replace it with a more complex logic that takes care of substrings, etc.
	grep(emoticon,tweets)
	#This will return a vector of elements from <tweets> which contain <emoticon>
}

emoticon.score.distributions <-
	sapply(emoticon.list, function(e){
		containing.indices <- FindMatches(e,tweets)
		score.dist <- tweet.scores[containing.indices]
		as.numeric(score.dist)
	})




###############################################
##### Part 3: Post-processing The results #####


## 1: Mean,sd
emoticon.sentiment.means <- sapply(emoticon.score.distributions,mean)
emoticon.sentiment.sds   <- sapply(emoticon.score.distributions,sd)



##2: Plot

clean.scores <- emoticon.score.distributions[sapply(emoticon.score.distributions,length)!=0]
emoticon.tags <-do.call(c,
						sapply(1:length(clean.scores), function(x)
							rep(names(clean.scores[x]),length(clean.scores[[x]])) )
)

allscores <- do.call(c, clean.scores)
df.scores<-data.frame(score=as.numeric(allscores),emoticon=emoticon.tags)
row.names(df.scores)<- 1:nrow(df.scores)
  #The above is a pretty roundabout way to achieve this. If you can think of something better, let me know

library(ggplot2)

p <- ggplot(data=df.scores,aes(
	x=score,
	y=reorder(emoticon,score,mean),
	color=emoticon,
	group=emoticon)) 

p.nonzero <- ggplot(data=df.scores[df.scores$score!=0,],aes(
	x=score,y=reorder(emoticon,score,mean),
	color=emoticon,
	group=emoticon)) 

p + geom_point(size=2,alpha=0.6, position = position_jitter(height = 0.2)) +
	geom_errorbarh(stat = "vline", xintercept = "mean",
				   height=0.6, size=1,
				   aes(xmax=..x..,xmin=..x..),color="black") +
	theme(legend.position="none") +
	xlab("Score") + ylab("Emoticon") +
	scale_y_discrete(labels=function(s) { gsub('\\\\','',s) }) #To remove the \\s from the emoticons
	

## 3: Oddities
which(grepl("\\:\\-\\(",tweets) & tweet.scores>5)



####################################################
#To Do (2013-09-09):
## Decide how to handle the substring cases, if any
####################################################


