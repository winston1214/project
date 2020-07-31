## 특정 키워드에 대한 기간별 워드클라우드
#####################################################################################################
keyword_wordcloud <- function(data = data, keyword = keyword){
  keyword_DT <- data
  keyword_sentence <- sentence_term_내용[names(sentence_term_내용) %in% keyword_DT$"민원접수번호"]
  keyword_dtm <- make_dtm(keyword_sentence, weight.type=1) # dtm 생성
  v <- sort(slam::col_sums(keyword_dtm), decreasing = T) # 빈도수 높은 순서로 내림차순 정렬
  d <- data.frame(word = names(v), freq = v) # 키워드와 빈도를 행렬로 가지는 데이터프레임 생성
  
  wordcloud(d$word, d$freq, random.order = F, rot.per = 0, colors = brewer.pal(8, 'Dark2')[8:1])
  imagedir <- paste("C:\\Users\\Admin\\Desktop\\complain\\result\\03.Topic\\", substr(Sys.Date(), 1, 4), sep="")
  imagedir <- paste(imagedir, substr(Sys.Date(), 6, 7), sep="_")
  imagedir <- paste(imagedir, substr(Sys.Date(), 9, 10), sep="_")
  imagedir <- paste(imagedir, keyword, "워드클라우드", sep="_")
  imagename <- paste(imagedir, ".jpeg", sep="")
  dev.copy(jpeg, filename = imagename)
  dev.off()
  dev.off()
  write.csv(d, file = paste(imagedir, ".csv", sep=""))
  return(keyword_dtm)
}
