setwd('C:/Users/Admin/Desktop/complain/Rscript') 
getwd()


Sys.getenv('JAVA_HOME')
# install.packages('https://cran.r-project.org/src/contrib/Archive/KoNLP/KoNLP_0.80.2.tar.gz',repos=NULL,type='source',
#                 INSTALL_opts = c('--no-lock')) # konlp
library(KoNLP)





# 2. list.files()를 통해 워킹 디렉토리 내에 R소스가 모두 있는지 확인
list.files()

# 3. 소스코드 실행
source('load_library.R', encoding = "UTF-8")
# Make Document-Term Matrix
source('make_dtm.R', encoding = "UTF-8")
# 1. raw data 로드
setwd('C:/Users/Admin/Desktop/complain/data') 
getwd()

# .csv file 불러오기
list.files()
# 확장자 csv파일의 리스트를 files에 저장
files <- list.files(pattern="*.csv") 
# 각 열을 리스트로 가지는 데이터프레임의 형태로 로드
DT <- rbindlist(lapply(files, fread)) 

colnames(DT)

DT$민원등록일 <- as.POSIXct(DT$민원등록일, format = '%Y-%m-%d', origin='1970-01-01', tz='Asia/Seoul')

# 3. 불필요한 민원 제거
# 2017년부터 2018년까지의 데이터를 분석 대상으로 선정
re_DT <- subset(DT, 민원등록일 >= '2017-01-01')

# 민원 내용이 15글자인 행 제거
re_DT <- subset(re_DT, nchar(민원내용)>=15 & nchar(민원내용)<=100)

# 중복 및 악성 민원 제거
re_DT <- re_DT[!duplicated(re_DT[,c('민원내용','주소','민원등록일')])]

# 불필요 객체 제거
rm(files)
rm(DT)

re_DT_add_1 <- sapply(re_DT$주소, function(x) stri_split_fixed(x, pattern = " ", omit_empty=TRUE)[[1]][1], USE.NAMES=F)
re_DT$민원인주소시도<-re_DT_add_1
re_DT$민원인주소시도<-gsub('전북','전라북도', re_DT$민원인주소시도)
#re_DT$민원인주소시도<-gsub('서울','서울특별시', re_DT$민원인주소시도)

# 시도가 전라북도인 데이터 테이블 생성
re_DT <- re_DT[grep("전라북도", re_DT$민원인주소시도),] 
#re_DT <- re_DT[grep("서울특별시", re_DT$민원인주소시도),] 
head(re_DT_add_1)

# 주소에서 시군구 가져오기
re_DT_add_2 <- sapply(re_DT$주소, function(x) stri_split_fixed(x, pattern = " ", omit_empty=TRUE)[[1]][2], USE.NAMES=F)
re_DT$민원인주소시군구<-re_DT_add_2
re_DT_add_1
head(re_DT_add_2)

# 주소에서 읍면동 가져오기
re_DT_add_3 <- sapply(re_DT$주소, function(x) stri_split_fixed(x, pattern = " ", omit_empty=TRUE)[[1]][3], USE.NAMES=F)
re_DT$민원인주소법정동<-re_DT_add_3
head(re_DT_add_3)

road_code <- read.table('C:/Users/Admin/Desktop/complain/preprocessing/road_code_total.txt', sep="|")

# 도로명 주소 테이블에서 필요한 부분만 추출
road_code_jeon<-subset(road_code, V5=='전라북도')
road_code_jeon<-subset(road_code_jeon, V4=='1')
aa<-unique(data.table(road_code_jeon$V9))
aa<-aa[-1,]

# 6. 민원내용에서 전북 법정동 주소가 있을 경우 주소로 가져오기
re_DT$민원내용주소법정동<-NA
for (i in 1:dim(aa)[1]) {
  dong <- grep(aa[i], re_DT$민원내용)
  for (j in dong){
    re_DT$민원내용주소법정동[j] <- aa[i]
  }
}
re_DT$민원내용주소법정동<-unlist(re_DT$민원내용주소법정동)
re_DT$최종민원주소<-NA
for(i in 1:dim(re_DT)[1]) {
  if(is.na(re_DT$민원내용주소법정동)[i] == 'FALSE') {
    re_DT$최종민원주소[i] <- re_DT$민원내용주소법정동[i]
  }else{
    re_DT$최종민원주소[i] <- re_DT$민원인주소법정동[i]
  }
}

# 8. 최종 민원 주소에서 도로명 주소를 법정동 주소로 변환
# 도로명 주소를 법정동 주소로 변환
# 도로명 주소
pattern <- as.character(road_code_jeon$V2)

# 법정동 주소
replacement <- as.character(road_code_jeon$V9)
for(i in seq_along(pattern)){
  re_DT$최종민원주소 <- gsub(pattern[i], replacement[i], re_DT$최종민원주소, fixed = TRUE)
}

re_DT$주소<-NULL
re_DT$민원인주소시도<-NULL
re_DT$민원인주소시군구<-NULL
re_DT$민원인주소법정동<-NULL

# 최종민원주소를 제외한 기존 주소 제거
re_DT$민원내용주소법정동<-NULL 

pattern_1 <- grep('[동][0-9]*[번길]', re_DT$최종민원주소, value=T)
replacement_1 <- gsub('[동][0-9]*[번길]*', '동', pattern_1)
for(i in seq_along(pattern_1)){
  re_DT$최종민원주소 <- gsub(pattern_1[i], replacement_1[i], re_DT$최종민원주소, fixed = TRUE)
}

# 면+α 를 면 으로 변경
# 최종민원주소에서 [면][0-9]로 시작하는 객체 추출
pattern_2 <- grep('[면][0-9]*[번길]', re_DT$최종민원주소, value=T)
replacement_2 <- gsub('[면][0-9]*[번길]*', '면', pattern_2)
for(i in seq_along(pattern_2)){
  re_DT$최종민원주소 <- gsub(pattern_2[i], replacement_2[i], re_DT$최종민원주소, fixed = TRUE)
}

# 읍+α 를 읍 으로 변경
# 최종민원주소에서 [읍][0-9]로 시작하는 객체 추출
pattern_3 <- grep('[읍][0-9]*[번길]', re_DT$최종민원주소, value=T) 
replacement_3 <- gsub('[읍][0-9]*[번길]*', '읍', pattern_3)
for(i in seq_along(pattern_3)){
  re_DT$최종민원주소 <- gsub(pattern_3[i], replacement_3[i], re_DT$최종민원주소, fixed = TRUE)
}

# 가+α 를 가 로 변경
pattern_4 <- grep('[가][0-9]*[번길]', re_DT$최종민원주소, value=T)
replacement_4 <- gsub('[가][0-9]*[번길]*', '가', pattern_4)
for(i in seq_along(pattern_4)){
  re_DT$최종민원주소 <- gsub(pattern_4[i], replacement_4[i], re_DT$최종민원주소, fixed = TRUE)
}

for (i in 1:dim(aa)[1]) {
  dong <- grep(aa[i], re_DT$최종민원주소)
  for (j in dong){
    re_DT$최종민원주소[j] <- aa[i]
  }
}
re_DT$최종민원주소<-unlist(re_DT$최종민원주소)
unique(re_DT$최종민원주소)

# 11. 1000개 샘플 추출 및 연번 매기기
re_DT<-re_DT[sample(nrow(re_DT), 1000)]
re_DT$민원접수번호 <- seq(1:nrow(re_DT))

# 불필요한 객체 제거
rm(aa); rm(pattern); rm(pattern_1); rm(pattern_2); rm(pattern_3); rm(pattern_4);
rm(replacement); rm(replacement_1); rm(replacement_2); rm(replacement_3); rm(replacement_4);
rm(road_code); rm(re_DT_add_1); rm(re_DT_add_2); rm(i); 
rm(re_DT_add_3); rm(road_code_jeon); rm(dong); rm(j);

