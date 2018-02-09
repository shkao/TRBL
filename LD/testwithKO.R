rm(list = ls())
library(pathview)
library(dplyr)

setwd("/Users/shkao/GitHub/TRBL/LD")
data <- read.delim("testwithKO.txt", header = TRUE)
colnames(data)[1] <- "KO"

data.summarized <- group_by(data, KO) %>% summarise_all(funs(mean)) %>% as.data.frame
row.names(data.summarized) <- data.summarized$KO

pv.out <-
    pathview(
        gene.data = data.summarized[,-1],
        pathway.id = "00140",
        species = "ko",
        kegg.native = T,
        multi.state = T,
        same.layer = T,
        out.suffix = "exp"
    )

