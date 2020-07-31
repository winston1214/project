library(igraph)
dtm <- removeSparseTerms(dtm_내용_전체민원, 0.95)	# term의 갯수를 조정, 가장 많이 사용되는 단어를 90%까지 남겨둔다.
dtmx <- as.matrix(dtm)
# change it to a Boolean matrix
dtmx[dtmx >= 1] <- 1 # 이진 행렬의 형태로 만들기 위해 2 이상인 숫자를 1로 변환
# transform into a term-term adjacency matrix
dtmx2 <- t(dtmx) %*% dtmx
# build a graph from the above matrix
g <- graph.adjacency(dtmx2, weighted=T, mode = "undirected")
# remove loops
g <- simplify(g)
# set labels and degrees of vertices
V(g)$label <- V(g)$name
V(g)$degree <- degree(g)
V(g)$color <- rgb(135, 206, 250, max = 255)
# plot the graph in layout1
layout1 <- layout.kamada.kawai(g) #그래프의 모형 설정
par(mar=c(1, 1, 1, 1)) # 시각화 마진 설정
plot(g, layout=layout.kamada.kawai)
aa <- data.table('키워드' = V(g)$label, 
                 '연결중심성' = as.numeric(degree(g)), 
                 '근접중심성' = as.numeric(closeness(g)),
                 '매개중심성' = as.numeric(betweenness(g)),
                 '위세중심성' = as.numeric(evcent(g)$vector)
)
setorder(aa, -'연결중심성') # 연결중심성을 기준으로 내림차순 정렬
# save plot and output data
imagedir <- paste("C:\\Users\\Admin\\Desktop\\complain\\result\\02.SNA", substr(Sys.Date(), 1, 4), sep="")
imagedir <- paste(imagedir, substr(Sys.Date(), 6, 7), sep="_")
imagedir <- paste(imagedir, substr(Sys.Date(), 9, 10), sep="_")
imagedir <- paste(imagedir, "SNA", sep="_")
imagename <- paste(imagedir, ".jpeg", sep="")
dev.copy(jpeg, filename = imagename)
dev.off()
dev.off()
write.csv(aa, file = paste(imagedir, ".csv", sep=""))

