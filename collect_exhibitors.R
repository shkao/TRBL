rm(list = ls())
library(rvest)
library(curl)
library(tidyverse)
library(WriteXLS)

main.url <- "https://www.mobileworldcongress.com/exhibitors"
main.html <-
  read_html(curl(main.url, handle = curl::new_handle("useragent" = "Mozilla/5.0")))

# 從主頁面中取得總頁數
page.tatal <- main.html %>%
  html_nodes(".dots+ .page-numbers") %>%
  html_text()

datalist = list()

# 對每一頁依次進行
for (i in 1:page.tatal) {
  # 建立第i頁的網址
  page.url <- paste0(main.url, "/page/", i)

  # 抓取第i頁中所有公司的連結
  company.urls <-
    read_html(curl(page.url, handle = curl::new_handle("useragent" = "Mozilla/5.0"))) %>%
    html_nodes(".entity") %>%
    html_attr("href")
  
  # 對該頁中抓到的所有連結，依序進行
  for (j in 1:length(company.urls)) {
    # 第j筆公司的網址
    company.url <- company.urls[j]

    # 抓取第i頁第j筆公司的網頁資料
    company.html <-
      read_html(curl(
        company.url,
        handle = curl::new_handle("useragent" = "Mozilla/5.0")
      ))
    
    # 從網頁中提取公司的名稱
    company.name <- company.html %>%
      html_nodes("h1") %>%
      html_text() %>%
      last

    # 提示使用者目前處理中的公司
    cat(paste0("Fetching company: ", company.name, " from page ", i, "...\n"))
    
    # 從網頁中提取公司的位置
    company.location <- company.html %>%
      html_nodes(".list-location") %>%
      html_text() %>%
      paste(collapse = ' ')
    
    # 從網頁中提取公司的國家
    company.country <- company.html %>%
      html_nodes(".list-country") %>%
      html_text() %>%
      paste(collapse = ' ') %>%
      trimws()
    
    # 從網頁中提取公司的簡述
    company.description <- company.html %>%
      html_nodes(".flex-100 p") %>%
      html_text() %>%
      paste(collapse = ' ')
    company.description <-
      gsub("\n", " ", company.description)
    
    # 從網頁中提取公司的聯絡方式
    company.contact <- company.html %>%
      html_nodes(".nopadding-bottom+ .flex-50 p") %>%
      html_text() %>%
      paste(collapse = ' ') %>%
      trimws()
    
    # 從網頁中提取公司的網址或其他聯絡方式
    company.get_in_touch <- company.html %>%
      html_nodes(".websitebox") %>%
      html_attr("href")
    if (length(company.get_in_touch) == 0) {
      company.get_in_touch = NA
    }
    
    # 從網頁中提取關於公司的tag
    company.tags <- company.html %>%
      html_nodes(".entity-tags") %>%
      html_text() %>%
      trimws()
    if (length(company.tags) == 0) {
      company.tags = NA
    }
    company.tags <- gsub("  ", "", company.tags)
    company.tags <- gsub("\r\n\r\n", "; ", company.tags)
    
    # 將這筆公司的所有資訊存成一個dataframe
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

    # 以index(i_j)為索引，將剛剛建立的dataframe存進datalist裡
    datalist[[index]] <- dat
  }
  Sys.sleep(3)
  remove(company.urls)
}

# 整合所有list，儲存為新的dataframe
company.all <- do.call(rbind, datalist)

# 將所有資料(剛剛建立的dataframe)匯出為Excel檔案
WriteXLS(company.all, "~/Desktop/companies.xls", row.names = FALSE)
