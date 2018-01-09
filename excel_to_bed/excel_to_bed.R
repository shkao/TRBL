#!/usr/bin/env Rscript

library("readxl")

args = commandArgs(trailingOnly=TRUE)

in_xls <- args[1]
out_bed <- paste0(tools::file_path_sans_ext(in_xls), ".bed")

df <- read_excel(in_xls, col_types = c("text", "numeric", "numeric", "text"))
write.table(df, file = out_bed, row.names = FALSE, sep = "\t", quote = FALSE)
