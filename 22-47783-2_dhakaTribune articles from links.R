library(rvest)
library(dplyr)
library(readr)
library(purrr)
library(tidyr)

# Load links CSV (if you have it saved)
links_data <- read_csv("dhakaTribune_links_with_labels.csv", show_col_types = FALSE)[,]

# Function to extract article details
extract_article_details <- function(url) {
  tryCatch({
    page <- read_html(url)
    closeAllConnections()
    Sys.sleep(1)
    
    # Extract text from all <p> tags
    panel_nodes <- page %>% html_nodes("div.articleBody")
    if (length(panel_nodes) > 0) {
      xml2::xml_remove(panel_nodes)
    }
    
    date_published <- page %>%
      html_node("span[itemprop='datePublished']") %>%
      html_attr("content")
    
    # Fallback if not found
    if (is.null(date_published)) {
      date_published <- NA
    }
    

# Final fallback if both failed
if (is.null(date_published)) date_published <- NA


# Final fallback if nothing is found
if (is.null(date_published)) date_published <- NA

    
    paragraphs <- page %>%
      html_nodes("p") %>%
      html_text() %>%
      paste(collapse = " ")  # Combine all text into one single string
    
    return(data.frame(
      article_text = paragraphs,
      date_published = date_published,
      stringsAsFactors = FALSE
    ))
  }, error = function(e) {
    message("Failed to scrape: ", url)
    return(data.frame(
      article_text = NA,
      stringsAsFactors = FALSE
    ))
  })
}

# Loop through all links and extract details
results <- links_data %>%
  mutate(full_url = paste0("", href)) %>%  # Assuming href is relative
  mutate(scraped = map(full_url, extract_article_details)) %>%
  unnest(scraped)

# Save to CSV
write_csv(results, "dhakaTribune_articles_with_text.csv")

cat("✅ Saved scraped articles with text to ddhakaTribune_articles_with_text.csv\n")
