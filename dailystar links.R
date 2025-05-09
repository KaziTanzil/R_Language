library(rvest)
library(dplyr)
library(readr)

# Base URL
base_url <- "https://www.thedailystar.net"

# Read homepage
homepage <- read_html(base_url)

# Extract <a> tags
a_nodes <- homepage %>% html_nodes("a")

# Get href and aria-label
links_data <- data.frame(
  href = a_nodes %>% html_attr("href"),
  aria_label = a_nodes %>% html_attr("aria-label"),
  stringsAsFactors = FALSE
)

# Filter: keep only valid hrefs and aria-labels (non-NA)
links_data <- links_data %>%
  filter(!is.na(href), !is.na(aria_label)) %>%
  mutate(
    href = ifelse(grepl("^http", href), href, paste0(base_url, href))
  ) %>%
  distinct()

# Save to CSV
write_csv(links_data, "dailystar_links_with_labels.csv")

cat("Saved", nrow(links_data), "links with aria-labels to dailystar_links_with_labels.csv\n")
