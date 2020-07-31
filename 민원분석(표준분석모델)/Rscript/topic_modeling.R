setwd('C:\\Users\\Admin\\Desktop\\complain\\Rscript') #워킹 디렉토리 설정

# EDA
source('05-1-1.keyword_chart.R', encoding = "cp949")
source('05-1-2.keyword_WordCloud.R', encoding = "cp949")
# 연관성 분석 (Association Rules)
source('05-2.keyword_arules.R', encoding = "cp949")
# 토픽 분석 (Topic Modeling)
source('05-3-1. find_topic_N.R', encoding = "UTF-8")
source('05-3-2. keyword_topic.R', encoding = "UTF-8")

# 1) 주차

re_DT_주차 <- keyword_chart(keyword = '주차')
dtm_주차 <- keyword_wordcloud(data = re_DT_주차, keyword = '주차')
keyword_arules(dtm = dtm_주차, keyword = '주차', supp = 0.03, conf = 0.15)
#결과값이 나오지 않을 경우 지지도 낮추기
find_topic_N(dtm = dtm_주차)
k <- 6 # 최적의 토픽 수 결정 후 확인, 수정
keyword_topic(data = re_DT_주차, dtm = dtm_주차, k = k, keyword = '주차')

# 2) 안전
re_DT_안전 <- keyword_chart(keyword = '안전')
dtm_안전 <- keyword_wordcloud(data = re_DT_안전, keyword = '안전')
keyword_arules(dtm = dtm_안전, keyword = '안전', supp = 0.2, conf = 0.15)
find_topic_N(dtm = dtm_안전)
k <- 10 # 최적의 토픽 수 결정 후 확인, 수정
keyword_topic(data = re_DT_안전, dtm = dtm_안전, k = k, keyword = '안전')
