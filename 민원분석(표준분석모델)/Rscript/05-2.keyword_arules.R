keyword_arules <- function(dtm = dtm, keyword = keyword, supp = supp, conf = conf){
  require(arules)
  require(arulesViz) #연관성분석에 필요한 패키지 로드
  dtmx <- as.matrix(dtm) # DTM 행렬 생성
  dtmx[dtmx>=1]<-1
  tmp <- as(dtmx, 'transactions') # 연관성 분석을 위한 transactions data로 변환
  rules_tmp <- apriori(tmp, parameter = list(supp = supp, conf = conf)) # 데이터에 apriori(연관성규칙알고리즘) 수행
  rules_sorted <- sort(rules_tmp, by = 'lift') # lift(연관성 정도)가 큰 순으로 나열
  
  
  par(mar=c(1, 1, 1, 1)) # 시각화 margin 설정
  plot(rules_sorted, method = 'graph', control = list(type = 'items'))
  imagedir <- paste("C:\\Users\\Admin\\Desktop\\complain\\result\\03.Topic", substr(Sys.Date(), 1, 4), sep="")
  imagedir <- paste(imagedir, substr(Sys.Date(), 6, 7), sep="_")
  imagedir <- paste(imagedir, substr(Sys.Date(), 9, 10), sep="_")
  imagedir <- paste(imagedir, keyword, "연관성분석", sep="_")
  imagename <- paste(imagedir, ".jpeg", sep="")
  dev.copy(jpeg, filename = imagename)
  dev.off()
  dev.off()
  write.csv(inspect(rules_sorted), file = paste(imagedir, ".csv", sep=""))
}