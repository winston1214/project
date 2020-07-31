#특정 키워드에 대한 자료에서 최적의 토픽수 결정
#####################################################################################################

find_topic_N <- function(dtm = dtm) {
	library(lda)
	library(topicmodels)
	library(Rmpfr)
	sequ <- seq(2, 30, 1)
	k = 10 # 토픽의 개수 설정
	burnin = 1000 
	iter = 1000
	keep = 50
	
	a1 <- dtm[row_sums(dtm) > 0, ]
	sample_data <- a1[1:20, ]
	fitted_ex <- lapply(sequ, function(k) LDA(sample_data, k = k, method = "Gibbs",
	                                          control = list(burnin = burnin, iter = iter, keep = keep)))
	best_model_logLik <- as.data.frame(as.matrix(lapply(fitted_ex, logLik)))
	best_model_logLik_df <- data.frame(topics=c(2:30), LL=as.numeric(as.matrix(best_model_logLik)))
	
	
	library(ggplot2)
	l_plot <- ggplot(best_model_logLik_df, aes(x=topics, y=LL)) + geom_line() + theme_bw() + 
	  xlab("Number of topics") + ylab("Log likelihood of the model")
  	imagedir <- paste("C:\\Users\\Admin\\Desktop\\complain\\result\\03.Topic", substr(Sys.Date(), 1, 4), sep="")
	imagedir <- paste(imagedir, substr(Sys.Date(), 6, 7), sep="_")
	imagedir <- paste(imagedir, substr(Sys.Date(), 9, 10), sep="_")
	imagedir <- paste(imagedir, "최적의_토픽수", sep="_")
	imagename <- paste(imagedir, ".jpeg", sep="")
	ggsave(imagename, plot = l_plot)
	k <- best_model_logLik_df[which.max(best_model_logLik_df$LL),]
	return(k)
}
