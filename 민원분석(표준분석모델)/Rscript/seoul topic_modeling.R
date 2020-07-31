setwd('C:\\Users\\Admin\\Desktop\\complain\\Rscript') #워킹 디렉토리 설정

# EDA
source('seoul keyword_chart.R', encoding = "utf-8")
source('seoul keyword_WordCloud.R', encoding = "utf-8")
# 연관성 분석 (Association Rules)
source('seoul keyword_arules.R', encoding = "utf-8")
# 토픽 분석 (Topic Modeling)
source('05-3-1. find_topic_N.R', encoding = "UTF-8")
source('05-3-2. keyword_topic.R', encoding = "UTF-8")

# 1) 주차

re_DT_주차 <- keyword_chart(keyword = '가로등')
dtm_주차 <- keyword_wordcloud(data = re_DT_주차, keyword = '가로등')
keyword_arules(dtm = dtm_주차, keyword = '가로등', supp = 0.01, conf = 0.15)
#결과값이 나오지 않을 경우 지지도 낮추기
find_topic_N(dtm = dtm_주차)
k <- 6 # 최적의 토픽 수 결정 후 확인, 수정
keyword_topic(data = re_DT_주차, dtm = dtm_주차, k = k, keyword = '가로등')

# 2) 안전
re_DT_안전 <- keyword_chart(keyword = '안전')
dtm_안전 <- keyword_wordcloud(data = re_DT_안전, keyword = '안전')
keyword_arules(dtm = dtm_안전, keyword = '안전', supp = 0.2, conf = 0.15)
find_topic_N(dtm = dtm_안전)
k <- 10 # 최적의 토픽 수 결정 후 확인, 수정
keyword_topic(data = re_DT_안전, dtm = dtm_안전, k = k, keyword = '안전')
