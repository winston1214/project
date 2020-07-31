keyword_chart <- function(keyword = keyword){
  library(lubridate)
  tmp <- sort(unique(unlist(sapply(keyword, grep, re_DT$민원내용, ignore.case=TRUE))), decreasing = F)
  keyword_DT <- re_DT[tmp]
  
  freq.all.DT <- table(format(keyword_DT$민원등록일,"%Y-%m"))	#전체 연도별 월별 건수
  freq.year.DT <- table(format(keyword_DT$민원등록일,"%Y"))	#연도별 건수
  freq.month.DT <- table(format(keyword_DT$"민원등록일","%m"))	#월별 건수
  freq.day.DT <- table(format(keyword_DT$"민원등록일","%A"))	#요일별 건수
  ad <- c(freq.day.DT[4], freq.day.DT[7], freq.day.DT[3],
          freq.day.DT[2], freq.day.DT[1], freq.day.DT[6], freq.day.DT[5]) # 월,화,수,목,금,토,일 저장
  
  #par(mfrow=c(2,2))
  
  plot(freq.all.DT, las = 2, type = "l", col = "lightblue", main = "전체 민원 빈도 그래프")
  imagedir <- paste("C:\\Users\\Admin\\Desktop\\complain\\result\\03.Topic\\", substr(Sys.Date(), 1, 4), sep="")
  imagedir <- paste(imagedir, substr(Sys.Date(), 6, 7), sep="_")
  imagedir <- paste(imagedir, substr(Sys.Date(), 9, 10), sep="_")
  imagedir <- paste(imagedir, keyword, sep="_")
  imagedir1 <- paste(imagedir, "기간별_민원_건수(Line_Chart)", sep="_")
  imagename <- paste(imagedir1, ".jpeg", sep="")
  dev.copy(jpeg, filename = imagename)
  dev.off()
  dev.off()
  
  barplot(freq.year.DT, las = 2, col = "lightblue", main = "연도별 민원 빈도 그래프")
  imagedir2 <- paste(imagedir, "연도별_민원_건수(Bar_Chart)", sep="_")
  imagename <- paste(imagedir2, ".jpeg", sep="")
  dev.copy(jpeg, filename = imagename)
  dev.off()
  dev.off()
  
  barplot(freq.month.DT, las = 2, col = "lightblue", main = "월별 민원 빈도 그래프")
  imagedir3 <- paste(imagedir, "월별_민원_건수(Bar_Chart)", sep="_")
  imagename <- paste(imagedir3, ".jpeg", sep="")
  dev.copy(jpeg, filename = imagename)
  dev.off()
  dev.off()
  
  barplot(ad, las = 2, col = "lightblue", main = "요일별 민원 빈도 그래프")
  imagedir4 <- paste(imagedir, "요일별_민원_건수(Bar_Chart)", sep="_")
  imagename <- paste(imagedir4, ".jpeg", sep="")
  dev.copy(jpeg, filename = imagename)
  dev.off()
  dev.off()
  keyword_DT[, 'type' := keyword[1]]
  return(keyword_DT)
}

