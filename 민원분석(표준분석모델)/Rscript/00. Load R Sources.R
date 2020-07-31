## Load Source File
#####################################################################################################
## library
# 패키지 확인 필수!(설치 필요)
#install.packages(c("rJava","stringr","hash","tau","Sejong","RSQLite","devtools"))
#install.packages('https://cran.r-project.org/src/contrib/Archive/KoNLP/KoNLP_0.80.2.tar.gz', repos=NULL, type="source", INSTALL_opts=c('--no-lock'))
library(KoNLP)
useNIADic()
setwd('C:/Users/USER/Desktop/강의자료20200716/analysis/Rscript') #워킹 디렉토리 설정
list.files()
source('load_library.R', encoding = "UTF-8")
## Make Document-Term Matrix
source('make_dtm.R', encoding = "UTF-8")