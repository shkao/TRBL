rm(list = ls())
#source("https://bioconductor.org/biocLite.R")
#biocLite("pathview")
library(pathview)
library(dplyr)

setwd("~/GitHub/TRBL/KEGG/Plot_KEGG_for_2_conditions")
data <- read.delim("data.txt", header = TRUE)
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

