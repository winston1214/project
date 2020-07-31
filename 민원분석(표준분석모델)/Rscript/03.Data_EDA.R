####################################################################################################
## 1. 기간별 히스토그램
freq_all_DT <- table(format(re_DT$"민원등록일","%Y-%m"))	#전체 연도별-월별 건수
freq_year_DT <- table(format(re_DT$"민원등록일","%Y"))	#연도별 건수
freq_month_DT <- table(format(re_DT$"민원등록일","%m"))	#월별 건수
freq_week_DT <- table(format(re_DT$"민원등록일","%A"))	#요일별 건수
path_ <- "C:/Users/Admin/Desktop/complain/result/01.EDA"
# 연도별-월별 라인 그래프 생성
imagedir <- paste(path_, substr(Sys.Date(), 1, 4), sep="")
imagedir <- paste(imagedir, substr(Sys.Date(), 6, 7), sep="_")
imagedir <- paste(imagedir, substr(Sys.Date(), 9, 10), sep="_")
imagedir1 <- paste(imagedir, "연도별_월별_민원_막대그래프", sep="_")
imagename <- paste(imagedir1, ".jpeg", sep="")
dev.copy(jpeg,filename = imagename)
dev.off()
dev.off()


barplot(freq_year_DT, las = 2, col = "lightblue", main = "연도별 민원 빈도 그래프")
imagedir2 <- paste(imagedir, "연도별_민원_막대그래프", sep="_")
imagename <- paste(imagedir2, ".jpeg", sep="")
dev.copy(jpeg,filename = imagename)
dev.off()
dev.off()

barplot(freq_month_DT, las = 2, col = "lightblue", main = "월별 민원 빈도 그래프")
imagedir3 <- paste(imagedir, "월별_민원_막대그래프", sep="_")
imagename <- paste(imagedir3, ".jpeg", sep="")
dev.copy(jpeg,filename = imagename)
dev.off()
dev.off()

barplot(c(freq_week_DT[4], freq_week_DT[7], freq_week_DT[3], 
          freq_week_DT[2], freq_week_DT[1], freq_week_DT[6], 
          freq_week_DT[5]), las = 2, col = "lightblue", main = "요일별 민원 빈도 그래프")
imagedir4 <- paste(imagedir, "요일별_민원_막대그래프", sep="_")
imagename <- paste(imagedir4, ".jpeg", sep="")
dev.copy(jpeg,filename = imagename)
dev.off()
dev.off()
######################################################################################

aa_list <- ls(pattern = "dtm_")
for(i in 1:length(aa_list)){
  v <- sort(slam::col_sums(get(aa_list[i])), decreasing = T)
  d <- data.frame(word = names(v), freq = v)
  #	d=subset(d,d$word!="사진")
  #	d=subset(d,d$word!="첨부")
  wordcloud(d$word, d$freq,scale = c(6,1.3), random.order = F, rot.per = 0, colors = brewer.pal(12,'Paired'), min.freq=10)
  imagedir <- paste(path_, substr(Sys.Date(), 1, 4), sep="")
  imagedir <- paste(imagedir, substr(Sys.Date(), 6, 7), sep="_")
  imagedir <- paste(imagedir, substr(Sys.Date(), 9, 10), sep="_")
  imagedir <- paste(imagedir, "워드클라우드", strsplit(aa_list[i], "dtm_")[[1]][2], sep="_")
  imagename <- paste(imagedir, ".jpeg", sep="")
  dev.copy(jpeg, filename = imagename)
  dev.off()
  dev.off()
  write.csv(d, file = paste(imagedir, ".csv", sep=""), col.names = F)
}
rm(d); rm(v); rm(freq_all_DT); rm(freq_year_DT); rm(freq_month_DT); rm(freq_week_DT); rm(i); 
rm(imagedir); rm(imagedir1); rm(imagedir2); rm(imagedir3); rm(imagedir4); rm(imagename); 
aa_list <- ls(pattern = "y_DT_"); rm(list=(aa_list));
aa_list <- ls(pattern = "ym_DT_"); rm(list=(aa_list));
rm(aa_list)