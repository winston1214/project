#토픽분석결과.jpeg, 토픽별/기간별 EDA.jpeg, 토픽별_처리부서_빈도표.csv
#####################################################################################################
keyword_topic <- function(data = data, dtm = dtm, k = k, keyword = keyword) {
	library(slam)
	burnin = 1000
	iter = 1000
	keep = 50
	a1 <- dtm[row_sums(dtm) > 0, ]
	a2 <- dtm[!(row_sums(dtm) > 0), ]
	result_lda <- LDA(a1, k = k, method = "Gibbs", control = list(burnin = burnin, iter = iter, keep = keep))
	result_topic <- as.matrix(topics(result_lda))
	result_terms <- as.matrix(terms(result_lda, 10))
	
	
  imagedir <- paste("C:\\Users\\Admin\\Desktop\\complain\\result\\03.Topic", substr(Sys.Date(), 1, 4), sep="")
	imagedir <- paste(imagedir, substr(Sys.Date(), 6, 7), sep="_")
	imagedir <- paste(imagedir, substr(Sys.Date(), 9, 10), sep="_")
	imagedir <- paste(imagedir, "토픽분석", sep="_")
	write.csv(result_terms, file = paste(imagedir, ".csv", sep=""))
	
	
	# remove non-zero entry 
	docnames <- as.numeric(a2$dimnames$Docs)
	re_data <- data[!docnames,]
	keyword_topic <- re_data[, Topic_Number := result_topic]
	for(i in 1:k){
		nam <- paste(keyword, "topic", i, sep="_")
		assign(nam, keyword_topic[grep(i, keyword_topic$"Topic_Number")])
	}

	
	aa_list <- ls(pattern = paste(keyword, "topic", sep="_"))

	
	
	for(i in 1:length(aa_list)){
		# 기간별 현황분석
		library(lubridate)
		freq.year.DT <- table(format(get(aa_list[i])$"민원등록일","%Y"))	#연도별 건수
		freq.month.DT <- table(format(get(aa_list[i])$"민원등록일","%m"))	#월별 건수
		freq.day.DT <- table(format(get(aa_list[i])$"민원등록일","%A"))	#요일별 건수
		par(mfrow=c(3,1))
		barplot(freq.year.DT, col = "lightblue", main = "연도별 민원 빈도 그래프")
		barplot(freq.month.DT, col = "lightblue", main = "월별 민원 빈도 그래프")
		ad <- c(freq.day.DT[4], freq.day.DT[7], freq.day.DT[3], freq.day.DT[2], freq.day.DT[1], freq.day.DT[6], freq.day.DT[5])
		
		barplot(ad, col = "lightblue", main = "요일별 민원 빈도 그래프")
		imagedir <- paste("C:\\Users\\Admin\\Desktop\\complain\\result\\03.Topic", substr(Sys.Date(), 1, 4), sep="")
		imagedir <- paste(imagedir, substr(Sys.Date(), 6, 7), sep="_")
		imagedir <- paste(imagedir, substr(Sys.Date(), 9, 10), sep="_")
		imagedir1 <- paste(imagedir, keyword, "토픽분석_기간별_현황분석",
		                   keyword, strsplit(aa_list[i], "_")[[1]][2], strsplit(aa_list[i], "_")[[1]][3], sep="_")
		imagename <- paste(imagedir1, ".jpeg", sep="")
		dev.copy(jpeg, filename = imagename)
		dev.off()
		dev.off()
	}
}
