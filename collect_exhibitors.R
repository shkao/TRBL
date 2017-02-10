rm(list = ls())
library(rvest)
library(curl)
library(tidyverse)
library(WriteXLS)

main.url <- "https://www.mobileworldcongress.com/exhibitors"
main.html <-
  read_html(curl(main.url, handle = curl::new_handle("useragent" = "Mozilla/5.0")))

page.tatal <- main.html %>%
  html_nodes(".dots+ .page-numbers") %>%
  html_text()

datalist = list()

for (i in 1:page.tatal) {
#for (i in 1:3) {
  page.url <- paste0(main.url, "/page/", i)

  company.urls <-
    read_html(curl(page.url, handle = curl::new_handle("useragent" = "Mozilla/5.0"))) %>%
    html_nodes(".entity") %>%
    html_attr("href")
  
  for (j in 1:length(company.urls)) {
    company.url <- company.urls[j]
    company.html <-
      read_html(curl(
        company.url,
        handle = curl::new_handle("useragent" = "Mozilla/5.0")
      ))
    
    company.name <- company.html %>%
      html_nodes("h1") %>%
      html_text() %>%
      last

    cat(paste0("Fetching company: ", company.name, " from page ", i, "...\n"))
    
    company.location <- company.html %>%
      html_nodes(".list-location") %>%
      html_text() %>%
      paste(collapse = ' ')
    
    company.country <- company.html %>%
      html_nodes(".list-country") %>%
      html_text() %>%
      paste(collapse = ' ') %>%
      trimws()
    
    company.description <- company.html %>%
      html_nodes(".flex-100 p") %>%
      html_text() %>%
      paste(collapse = ' ')
    company.description <-
      gsub("\n", " ", company.description)
    
    company.contact <- company.html %>%
      html_nodes(".nopadding-bottom+ .flex-50 p") %>%
      html_text() %>%
      paste(collapse = ' ') %>%
      trimws()
    
    company.get_in_touch <- company.html %>%
      html_nodes(".websitebox") %>%
      html_attr("href")
    if (length(company.get_in_touch) == 0) {
      company.get_in_touch = NA
    }
    
    company.tags <- company.html %>%
      html_nodes(".entity-tags") %>%
      html_text() %>%
      trimws()
    if (length(company.tags) == 0) {
      company.tags = NA
    }
    company.tags <- gsub("  ", "", company.tags)
    company.tags <- gsub("\r\n\r\n", "; ", company.tags)
    
    index = paste0(i, "_", j)
    dat <-
      data.frame(
        page = i,
        name = company.name,
        location = company.location,
        country = company.country,
        description = company.description,
        contact = company.contact,
        get_in_touch = company.get_in_touch,
        tags = company.tags
      )
    
    datalist[[index]] <- dat
  }
  Sys.sleep(3)
  remove(company.urls)
}

company.all <- do.call(rbind, datalist)
WriteXLS(company.all, "~/Desktop/companies.xls", row.names = FALSE)
