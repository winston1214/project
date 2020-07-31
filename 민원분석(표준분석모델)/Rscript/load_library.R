#####################################################################################################
# Script id   : load_library.R
# Script Name : 분석에 필요한 패키지 설치 및 실행
# Input       : 패키지
# Output      : installP
# Author      : 김태환
# sub author  : 김아현
# Date        : 2016.12.05
#####################################################################################################
assign("installP", function(pckgs){
    ins <- function(pckg, mc){
        add <- paste(c(" ", rep("-", mc+1-nchar(pckg)), " "), collapse = "");
        if( !require(pckg,character.only=TRUE) ){
            reps <- c("http://cran.nexr.com", "http://cloud.r-project.org");
            for (r in reps) try(utils::install.packages(pckg, repos=r), silent=TRUE);
            if(!require(pckg,character.only = TRUE)){   cat("Package: ",pckg,add,"not found.\n",sep="");
            }else{                                      cat("Package: ",pckg,add,"installed.\n",sep="");}
        }else{                                          cat("Package: ",pckg,add,"is loaded.\n",sep=""); } }
    invisible(suppressMessages(suppressWarnings(lapply(pckgs,ins, mc=max(nchar(pckgs)))))); cat("\n"); 
})
installP(c(
	"tm",
	"SnowballC", 
	"xlsx", 
	"wordcloud", 
	"foreach", 
	"doParallel", 
	"corrplot", 
	"extrafont", 
	"ggplot2",
	"sna",
	"igraph", 
	"lubridate", 
	"cluster", 
	"data.table",
	"dplyr",
	"lda",
	"topicmodels",
	"Rmpfr",
	"slam",
	"sqldf",
	"tcltk",
	"stringi",
	"stringr",
	"arules",
	"arulesViz",
	"openNLP"))
#####################################################################################################