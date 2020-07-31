#####################################################################################################
# Script id   : make_dtm.R
# Script Name : 문서-단어 행렬(Document-Term Matrix) 생성 함수
# Input       : 
# Output      : make_dtm
# Author      : 김태환
# sub author  : 김아현
# Date        : 2016.12.05
#####################################################################################################
# morph : 문장별 단어 벡터(character vector)의 리스트 객체(리스트 수=문장 수)
# weight.type : 가중치 타입(1=TF, 2=BINARY, 3=TF-IDF)
make_dtm <- function(morph=morph, weight.type=1){
  control <- switch(weight.type, 
                    list(weighting = function(x) weightTf(x)),
                    list(weighting = function(x) weightBin(x)),
                    list(weighting = function(x) weightTfIdf(x, normalize=T))
  )
  # 단어별 빈도 생성
  morph <- unname(lapply(morph, table))
  # Document Term Matrix 생성
  v <- unlist(morph)
  i <- names(v)
  allTerms <- sort(unique(as.character(i)))
  i <- match(i, allTerms) # Term index
  j <- rep(seq_along(morph), sapply(morph, length))
  docs <- as.character(1:length(morph))
  m <- slam::simple_triplet_matrix(i = i, j = j, v = as.numeric(v),
                                   nrow = length(allTerms),
                                   ncol = length(morph),
                                   dimnames = list(Terms = allTerms, Docs = docs))
  # weighting 처리
  bg <- control$bounds$global
  if (length(bg) == 2L && is.numeric(bg)){
    rs <- row_sums(m > 0)
    m <- m[(rs >= bg[1]) & (rs <= bg[2]),]
  }
  x <- slam::as.simple_triplet_matrix(m)
  # class 구분
  if(!is.null(dimnames(x))) {names(dimnames(x)) <- c("Terms", "Docs")}
  class(x) <- c("TermDocumentMatrix", "simple_triplet_matrix")
  dtm <- t(x)
  # weighting 부여
  weighting <- control$weighting
  dtm <- weighting(dtm)
  return(dtm)
}
#####################################################################################################