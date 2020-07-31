setkey(re_DT, 민원등록일) 
pyear <- strftime(re_DT$"민원등록일", format="%Y")
pmonth <- strftime(re_DT$"민원등록일", format="%m")
pweek <- strftime(re_DT$"민원등록일", format="%A")
re_DT[, pyear := pyear]
re_DT[, pmonth := pmonth]
re_DT[, pweek := pweek]

# 2. 월별/연도별-월별 데이터 테이블 생성 
# 전체민원
# 1. 연도별
for(i in 1:length(unique(re_DT$pyear))){
  nam <- paste0("y_DT_", unique(re_DT$pyear)[i])
  assign(nam, subset(re_DT, re_DT$pyear == unique(re_DT$pyear)[i]))
}
# 2. 연도별-월별
for(i in 1:length(unique(re_DT$pyear))){
  for(j in 1:length(unique(re_DT$pmonth))){
    nam <- paste0("ym_DT_", unique(re_DT$pyear)[i], "_", unique(re_DT$pmonth)[j])
    assign(nam, subset(re_DT, c(re_DT$pyear == unique(re_DT$pyear)[i] & re_DT$pmonth == unique(re_DT$pmonth)[j])))
  }
}
rm(i)
rm(nam)
tmp <- ls(pattern="DT")
for(i in 1:length(tmp)){
  if(dim(get(tmp[i]))[1] == 0)	rm(list=tmp[i])
}

setkey(re_DT, 민원접수번호)	# 번호를 기준으로 정렬
sentence <- re_DT$'민원내용'
nouns=sapply(sentence,extractNoun,USE.NAMES=F)
nouns=sapply(nouns, function(x) gsub("[[:digit:]]","",x)) # 숫자 제거
nouns=sapply(nouns, function(x) gsub("[[:blank:]]","",x)) # 공백 제거
nouns=sapply(nouns, function(x) gsub("[[:space:]]","",x)) # 띄어쓰기 제거
nouns=sapply(nouns, function(x) gsub("[[:punct:]]","",x)) # 특수문자 제거
nouns=sapply(nouns, function(x) gsub("\\d+","",x)) # digit으로 뽑히지 않은 숫자 제거
nouns=sapply(nouns, function(x) gsub("\\(,+","",x)) 
nouns=sapply(nouns, function(x) gsub("<,*?>>","",x)) 
nouns=sapply(nouns, function(x) gsub("★","",x)) 
nouns=sapply(nouns, function(x) gsub(" ","",x)) 
nouns=sapply(nouns, function(x) gsub('[[]~!@#$%&*()_+=?<>,./"]',"",x)) # punct로 제거되지 않은 특수문자 제거
nouns=sapply(nouns, function(x) gsub("[A-Za-z]","",x)) # 알파벳 제거
nouns=sapply(nouns, function(x) Filter(function(x){nchar(x)>=2}, x)) # 2자 이상의 명사만 추출
nouns=sapply(nouns, function(x) Filter(function(x){nchar(x)<=5}, x)) # 5자 이하의 명사만 추출

# 불필요 단어 및 중복 단어 체크
# 불필요 단어 및 오추출된 단어 확인
check=unlist(nouns)
check=table(check)
check=sort(check, decreasing = TRUE) # 상위 100개 단어만 출력
head(check)

############불필요 단어 제거###################
nouns=sapply(nouns, function(x) gsub("부안군","부안",x)) 
nouns=sapply(nouns, function(x) gsub("익산시","익산",x)) 
nouns=sapply(nouns, function(x) gsub("들이","",x))
nouns=sapply(nouns, function(x) gsub("전라북도","",x))
nouns=sapply(nouns, function(x) gsub("민원","",x))
nouns=sapply(nouns, function(x) gsub("답변","",x))
nouns=sapply(nouns, function(x) gsub("저희","",x))
nouns=sapply(nouns, function(x) gsub("처리","",x))
nouns=sapply(nouns, function(x) gsub("하지","",x))
nouns=sapply(nouns, function(x) gsub("하기","",x))
nouns=sapply(nouns, function(x) gsub("하시","",x))
nouns=sapply(nouns, function(x) gsub("해서","",x))
nouns=sapply(nouns, function(x) gsub("해서","",x))
nouns=sapply(nouns, function(x) gsub("ㅠ","",x))
nouns=sapply(nouns, function(x) gsub("ㅡ","",x))
nouns=sapply(nouns, function(x) gsub("[[:digit:]]","",x)) # 숫자 제거
nouns=sapply(nouns, function(x) gsub("[[:blank:]]","",x)) # 공백 제거
nouns=sapply(nouns, function(x) gsub("[[:space:]]","",x)) # 띄어쓰기 제거
nouns=sapply(nouns, function(x) gsub("[[:punct:]]","",x)) # 특수문자 제거
nouns=sapply(nouns, function(x) gsub("\\d+","",x)) # digit으로 뽑히지 않은 숫자 제거
nouns=sapply(nouns, function(x) gsub("\\(,+","",x)) 
nouns=sapply(nouns, function(x) gsub("<,*?>>","",x)) 
nouns=sapply(nouns, function(x) gsub("★","",x)) 
nouns=sapply(nouns, function(x) gsub(" ","",x)) 
nouns=sapply(nouns, function(x) gsub('[[]~!@#$%&*()_+=?<>,./"]',"",x)) # punct로 제거되지 않은 특수문자 제거
nouns=sapply(nouns, function(x) gsub("[A-Za-z]","",x)) # 알파벳 제거
nouns=sapply(nouns, function(x) Filter(function(x){nchar(x)>=2}, x)) # 2자 이상의 명사만 추출
nouns=sapply(nouns, function(x) Filter(function(x){nchar(x)<=5}, x)) # 5자 이하의 명사만 추출

# 형태소 분석 결과의 rowname에 번호 입력
sentence_term <- nouns
names(sentence_term)[1:length(sentence_term)] <- c(re_DT$'민원접수번호')
sentence_term_내용 <- sentence_term

rm(sentence); rm(sentence_term);
#####################################################################################################

## Make Term-Document Matrix
#####################################################################################################
## 데이터 형태별 형태소 결과 저장 후 DTM 생성
# 1. 글내용 전체민원
sentence_내용_전체민원 <- sentence_term_내용
dtm_내용_전체민원 <- make_dtm(sentence_내용_전체민원, weight.type=1)
# 2. 연도별 글내용 민원
aa_list <- ls(pattern = "y_DT_")
for(i in 1:length(aa_list)){
  nam <- paste("sentence", "내용", aa_list[i], sep="_")
  assign(nam, sentence_term_내용[names(sentence_term_내용) %in% get(aa_list[i])$"민원접수번호"])
}
for(i in 1:length(aa_list)){
  nam <- paste("dtm", "내용", aa_list[i], sep="_")
  assign(nam, make_dtm(get(ls(pattern = "sentence_내용_y_DT")[i]), weight.type=1))
}
# 3. 연도별-월별 글내용 민원
aa_list <- ls(pattern = "ym_DT_")
for(i in 1:length(aa_list)){
  nam <- paste("sentence", "내용", aa_list[i], sep="_")
  assign(nam, sentence_term_내용[names(sentence_term_내용) %in% get(aa_list[i])$"민원접수번호"])
}
for(i in 1:length(aa_list)){
  nam <- paste("dtm", "내용", aa_list[i], sep="_")
  assign(nam, make_dtm(get(ls(pattern = "sentence_내용_ym_DT")[i]), weight.type=1))
}
#####################################################################################################

## 불필요한 객체 제거
#####################################################################################################
rm(i); rm(j); rm(aa_list); rm(nam);

