# Load required libraries
library(rvest)
library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(tm)
library(tokenizers)
library(stringr)
library(topicmodels)
library(wordcloud)
library(RColorBrewer)
library(tidytext)
library(ggplot2)

# ----------------------------
# Step 1: Scrape article links and titles from Bangla Tribune homepage
# ----------------------------

base_url <- "https://www.banglatribune.com/"

# Read homepage
homepage <- read_html(base_url)

# Extract <a> tags with class 'link_overlay'
a_nodes <- homepage %>% html_nodes("a.link_overlay")

# Extract href and title attributes
links_data <- data.frame(
  href = a_nodes %>% html_attr("href"),
  title = a_nodes %>% html_attr("title"),
  stringsAsFactors = FALSE
)

# Filter valid links and fix relative URLs
links_data <- links_data %>%
  filter(!is.na(href), !is.na(title)) %>%
  mutate(
    href = ifelse(grepl("^http", href), href, paste0(base_url, href))
  ) %>%
  distinct()

# Save links data
output_links <- "D:/IDS/Final/BanglaTribune_links_with_labels.csv"
write_csv(links_data, output_links)

cat("Article Titles Extracted:\n")
print(links_data$title)
cat("\nSaved", nrow(links_data), "links with titles to", output_links, "\n\n")

# ----------------------------
# Step 2: Scrape article text and publication date for first 5 articles
# ----------------------------

links_data_subset <- read_csv(output_links, show_col_types = FALSE) 

extract_article_details <- function(url) {
  tryCatch({
    page <- read_html(url)
    Sys.sleep(1)  # be polite
    
    # Extract publication date
    date_published <- page %>%
      html_node("span.tts_time") %>%
      html_attr("content")
    
    if (is.null(date_published)) date_published <- NA
    
    # Remove side panels or ads within articleBody divs
    panel_nodes <- page %>% html_nodes("div.articleBody")
    if (length(panel_nodes) > 0) xml2::xml_remove(panel_nodes)
    
    # Extract all paragraphs text, join as one string
    paragraphs <- page %>%
      html_nodes("p") %>%
      html_text() %>%
      paste(collapse = " ")
    
    data.frame(
      article_text = paragraphs,
      date_published = date_published,
      stringsAsFactors = FALSE
    )
  }, error = function(e) {
    message("Failed to scrape: ", url)
    data.frame(article_text = NA, date_published = NA)
  })
}

results <- links_data_subset %>%
  mutate(scraped = map(href, extract_article_details)) %>%
  unnest(cols = scraped)

# Save scraped article details
output_texts <- "D:/IDS/Final/BanglaTribune_articles_with_text.csv"
write_csv(results, output_texts)
cat("Saved", nrow(results), "scraped articles with text to", output_texts, "\n\n")

# ----------------------------
# Step 3: Text cleaning and preprocessing
# ----------------------------

# Load scraped article data
article_data <- read_csv(output_texts, show_col_types = FALSE)

# Convert to UTF-8 (safe encoding)
texts <- iconv(article_data$article_text, from = "", to = "UTF-8")

# Bangla stopwords list
bangla_stopwords <- c(
  # Pronouns
  "আমি", "আমার", "আমরা", "আমাদের", "তুমি", "তোমার", "তোমরা", "তোমাদের", "তাদের", "তাদেরকে","তাকে","তোর",
  "সে", "তাহার", "তাহারা", "তাদের", "তিনি", "তার", "তারা", "উনি", "উনার", "এরা", "ওরা",
  "এই", "ওই", "উহা", "এটা", "ওটা", "এটি", "ওটি", "তা", "তুমি", "তুই", "তোরা","আরও",
  
  # Interrogatives
  "কে", "কাকে", "কী", "কি", "কেন", "কখন", "কখনো", "কোথায়", "কোথা", "কিভাবে", "কেমন", "কার", "কারা",
  
  # Relative pronouns
  "যে", "যার", "যাদের", "যাকে", "যারা", "যাদেরকে", "যাহারা", "যাহার", "যেটা", "যেখানে", "যখন", "যদিও", "যেহেতু", "যত", "যতই", "যদি",
  
  # Auxiliary verbs & verbal particles
  "হয়", "হয়েছে", "হয়নি", "হয়ে", "হলেও", "হল", "হলো", "হতে", "হব", "হবে", "হবেন", "হয়তো", "হচ্ছি", "হচ্ছে", "হচ্ছিল", "হই", "হইনি", "হইতেছে",
  "ছিল", "ছিলাম", "ছিলেন", "ছিলো", "থাকবে", "থাকে", "থাকেন", "থাকতে", "থেকে", "থেমে", "থাকায়", "থাকলেও",
  "করেছে", "করেন","করা", "করে", "করেনি", "করতে", "করানো", "করলে", "করাই", "করবো", "করছিলেন", "করেছিল", "করছেন",
  "দিয়ে", "দিয়েছে", "দেন", "দেই", "দেওয়া", "দেও", "দিতেছে", "নিতে", "নেন", "নেওয়া", "নেও", "নিয়ে", "নিয়েছে", "নেওয়ায়", "নিতেই",
  "বলেছে", "বলেন", "বলে", "বললেন", "বলছি", "বলবো", "বলল", "বল", "জানায়", "জানানো", "জানিয়ে", "জানেন", "জানি", "জানিয়েছে", "জানাতে","মনে","মতো" , "দিয়ে" ,"ধরে","করেছেন","কোনো" ,"করার",
  
  # Conjunctions & connectors
  "এবং", "অথবা", "কিন্তু", "তবে", "তাই", "তাতে", "তবুও", "তবু", "তাছাড়া", "তাছাড়া", "তাও", "তবে", "অথচ", "অতএব", "অবশ্য", "অর্থাৎ", "এবং",
  "ইত্যাদি", "যদিও", "তাইনা", "তাইও", "তাইলে", "তথাপি",
  
  # Demonstratives
  "এই", "ওই", "সেই", "এমন", "তেমন", "একই", "একটি", "সেটা", "এত", "এটা", "ওটা", "সেইটা", "সেইটি", "ওইটা", "এগুলো", "ওগুলো", "এদের", "ওদের",
  
  # Adverbs and others
  "আবার", "আর", "এখন", "তখন", "আগে", "পরে", "সকাল", "সন্ধ্যায়", "রাত", "সব", "সবাই", "সবসময়", "সবকিছু", "কিছু", "অনেক", "প্রায়", "বেশি", "কম", "যথেষ্ট",
  "দ্রুত", "ধীরে", "ধীরে", "চলে", "গেছে", "গেল", "গেলো", "যায়", "যেতে", "এসেছে", "চলছে", "গিয়েও", "গেলেও", "গেলেন", "গিয়েছেন",
  "একটা",  "ট্রিবউন","বাংলাদেশ",
  # Prepositions and postpositions
  "জন্য", "পরে", "আগে", "মধ্যে", "উপর", "নিচে", "পাশে", "ভেতরে", "বাইরে", "সঙ্গে", "সহ", "বিনা", "বিনামূল্যে", "নিয়ে", "দিকে", "ওপর", "মাথায়",
  "থেকে", "দিকে", "পর্যন্ত", "দিকে", "দিকে", "সামনে", "পিছনে",
  
  # Time related
  "কাল", "গতকাল", "আজ", "আগামী", "আগামীকাল", "এখনো", "তখনো", "সন্ধ্যায়", "সকাল", "রাত", "দুপুর", "সময়", "সময়ে", "সময়", "সময়েই", "ততক্ষণ", "এতক্ষণ",
  
  # Quantifiers / determiners
  "অনেক", "অল্প", "বেশি", "কম", "সকল", "কিছুটা", "প্রতিটি", "কয়েক", "দুই", "তিন", "চার", "পাঁচ", "সাত", "দশ", "সব", "সবার", "সবারই", "সবাই",
  
  # Other frequent non-content words
  "ও", "না", "হ্যাঁ", "তাই", "এ", "ই", "উ", "অ", "ওই", "সেই", "এই", "ওটা", "এইটা", "তাতে", "এতেও", "এতে", "তাতে", "রয়েছে", "হয়েছে", "নামেনি",
  "অকে", "পড়েছেন", "যায়", "ভেতর", "হয়ে", "হওয়ার", "দেখা", "ধরন", "সামান্য", "বেশিরভাগ", "কমেছে", "পড়েন", "কারণে", "অসংখ্য", "বিকল", "চলে", "এসেছে",
  "বন্ধ", "হাঁটু", "সমান", "সারা", "সড়কেও", "পরিষ্কার", "তখন", "তখনই", "যাবে", "হয়েই", "যাহারা", "যারপর", "যথা", "যে কারণে", "প্রভাবে", "টানা", "কমলেও",
  "দুর্ভোগে", "পশ্চিম", "উলন", "পানি", "অভিযোগ", "পর্যন্ত", "থাকতে",
  "হাজার", "কোনও", "কথা", "টাকা", "হিসেবে", "কাজ", "আছে", "নতুন", "দেশের", "দেওয়া",
  "বিভিন্ন", "পারে", "নাম", "শুরু", "বাংলা", "নেই", "মাধ্যমে" , "তৈরি", "এসব", "বিশেষ", "লাখ", "করছে", "দিতে",
  "বৃহস্পতিবার", "শুধু", "কাছে", "জানান", "কোটি",
  "বলা", "সালে", "বিষয়ে") 


stopword_pattern <- paste0("\\b(", paste(bangla_stopwords, collapse = "|"), ")\\b")

# Remove stopwords using regex replacement
cleaned_texts <- texts %>%
  str_replace_all(stopword_pattern, " ") %>%
  str_squish()

# Create a text corpus from cleaned texts
corpus <- VCorpus(VectorSource(cleaned_texts))

# Generic custom remover
remove_custom_pattern <- content_transformer(function(x, pattern) {
  gsub(pattern, " ", x)
})

# Case-insensitive removal of jwari.fetch(...) links
remove_jwari_fetch <- content_transformer(function(x) {
  gsub("(?i)jwari\\.fetch\\(.*?\\);", " ", x, perl = TRUE)
})

# Remove text inside parentheses including the parentheses
remove_parentheses_text <- content_transformer(function(x) {
  gsub("\\([^)]*\\)", " ", x)
})

bangla_digits <- "[০-৯]"
bangla_punctuation <- "[,!?।॥ঃ“”‘’—()/\\.-:]"    # Escaped dot and backslash

corpus <- tm_map(corpus, remove_jwari_fetch)
corpus <- tm_map(corpus, remove_parentheses_text)
corpus <- tm_map(corpus, remove_custom_pattern, bangla_digits)
corpus <- tm_map(corpus, remove_custom_pattern, bangla_punctuation)            # Remove punctuation
corpus <- tm_map(corpus, stripWhitespace)

# Convert corpus back to character vector (trimmed)
clean_texts_final <- trimws(sapply(corpus, as.character))

# ----------------------------
# Step 4: Tokenize cleaned texts
# ----------------------------

non_empty_indices <- which(clean_texts_final != "")
clean_texts_final_filtered <- clean_texts_final[non_empty_indices]

tokenized_data <- tokenize_words(clean_texts_final_filtered, lowercase = FALSE, strip_punct = FALSE)


cat("Tokenized words per document (sample):\n")
for (i in seq_along(tokenized_data)) {
  cat(paste0("Text ", i, " tokens:\n"))
  print(tokenized_data[[i]])
  cat("\n")
}

# ----------------------------
# Step 5: Compare original and cleaned samples
# ----------------------------
cat("Sample original vs cleaned documents:\n\n")

for (i in 1:min(15, length(texts))) {
  cat(paste0("Document ", i, " (Original):\n"))
  cat(texts[i], "\n\n")
  
  cat(paste0("Document ", i, " (Cleaned):\n"))
  cat(as.character(corpus[[i]]), "\n\n")
}

# ----------------------------
# Step 6: Topic Modeling with LDA
# ----------------------------

# Create Document-Term Matrix
dtm <- DocumentTermMatrix(corpus)

# Remove empty documents (rows with all 0s)
row_totals <- apply(dtm, 1, sum)
dtm <- dtm[row_totals > 0, ]

# Optional: report how many documents were removed
# Remove empty documents (rows with all 0s)
row_totals <- apply(dtm, 1, sum)
dtm <- dtm[row_totals > 0, ]

# Optional: report how many documents were removed
empty_docs <- which(row_totals == 0)
cat("Removed", length(empty_docs), "empty documents.\n")


# Set number of topics
num_topics <- 5

# Fit LDA model
lda_model <- LDA(dtm, k = num_topics, control = list(seed = 42))

# Show top terms per topic
top_terms <- terms(lda_model, 10)
cat("Top Terms for Each Topic:\n")
print(top_terms)

# ----------------------------
# Step 7: Wordcloud generation
# ----------------------------

cat("\n=== Step 7: Wordcloud & Top 20 Bar Plot ===\n")

# Create frequency dataframe
dtm_matrix <- as.matrix(dtm)
word_freq <- colSums(dtm_matrix)
df_bangla <- data.frame(word = names(word_freq), freq = word_freq)

# Define output paths
wordcloud_output <- paste0(output_dir, "wordcloud_final.png")
barplot_output <- paste0(output_dir, "barplot_top20_words.png")

# Use available Bangla-capable font
font_family <- ifelse("Arial Unicode MS" %in% windowsFonts(), "Arial Unicode MS",
                      ifelse("Nirmala UI" %in% windowsFonts(), "Nirmala UI", "Arial"))

# -------- Wordcloud --------

# Save to PNG
png(wordcloud_output, width = 1000, height = 800)
suppressWarnings(
  wordcloud(words = df_bangla$word,
            freq = df_bangla$freq,
            min.freq = 3,
            max.words = 100,
            random.order = FALSE,
            colors = brewer.pal(8, "Dark2"),
            family = font_family)
)
dev.off()

# Show Wordcloud in RStudio (new window)
suppressWarnings({
  dev.new()
  wordcloud(words = df_bangla$word,
            freq = df_bangla$freq,
            min.freq = 3,
            max.words = 100,
            random.order = FALSE,
            colors = brewer.pal(8, "Dark2"),
            family = font_family)
})
cat("✅ Wordcloud saved to:", wordcloud_output, "\n")


# -------- Bar Plot: Top 20 words --------

# Get top 20 most frequent words
top_20 <- df_bangla %>% arrange(desc(freq)) %>% slice_head(n = 20)
print(top_20)

# Create bar plot
bar_plot <- ggplot(top_20, aes(x = reorder(word, freq), y = freq)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 20 Most Frequent Words",
       x = "Words",
       y = "Frequency") +
  theme_minimal(base_family = font_family)

# Show in RStudio
suppressWarnings({
  dev.new()
  print(bar_plot)
})

# Save as PNG
suppressWarnings({
  ggsave(barplot_output, plot = bar_plot, width = 10, height = 6, units = "in")
})
cat("✅ Barplot saved to:", barplot_output, "\n")


# -------------------------------------
# Step 2–6: Bar Plots for All 5 Topics
# -------------------------------------

cat("\n=== Steps 2–6: Top 10 Words per Topic (with Frequency Barplots) ===\n")

topic_colors <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e")

for (i in 1:5) {
  cat(paste0("\n=== Topic ", i, " ===\n"))
  
  # Get top terms for topic i
  top_terms <- terms(lda_model, 10)[, i]
  
  # Get their frequency
  freq_df <- df_bangla %>% filter(word %in% top_terms)
  
  # Replace NAs with 0 (e.g., if a word isn't found in corpus anymore)
  freq_df$freq[is.na(freq_df$freq)] <- 0
  
  # Print frequency table
  print(freq_df)
  
  # Create bar plot
  plot_i <- ggplot(freq_df, aes(x = reorder(word, freq), y = freq)) +
    geom_bar(stat = "identity", fill = topic_colors[i]) +
    coord_flip() +
    labs(title = paste("Top 10 Words in Topic", i), x = "Words", y = "Frequency") +
    theme_minimal(base_family = ifelse("Nirmala UI" %in% windowsFonts(), "Nirmala UI", "Arial"))
  
  # Show in RStudio
  suppressWarnings({
    dev.new()
    print(plot_i)
  })
  
  # Save plot
  output_path <- paste0(output_dir, "barplot_topic", i, ".png")
  suppressWarnings({
    ggsave(output_path, plot = plot_i, width = 8, height = 6)
  })
  
  cat("✅ Saved barplot_topic", i, ".png to ", output_dir, "\n")
}

# --- Step 7: Sort Documents and Label Topics ---

cat("\n=== Step 7: Sorting Documents by Dominant Topic ===\n")

# Get document-topic probabilities from the LDA model
doc_topic_probs <- posterior(lda_model)$topics

# Assign dominant topic for each document
dominant_topic <- apply(doc_topic_probs, 1, which.max)

# Create a data frame with document IDs, dominant topic, and max probability
doc_labels <- data.frame(
  Document = 1:nrow(doc_topic_probs),
  Dominant_Topic = dominant_topic,
  Probability = apply(doc_topic_probs, 1, max)
)

# Calculate row totals of the Document-Term Matrix (DTM) to find non-empty docs
row_totals <- apply(dtm, 1, sum)

# Identify indices of documents with non-zero terms in DTM
non_empty_docs <- which(row_totals > 0)

# Filter dtm and article_data to keep only non-empty documents (must keep lengths aligned)
dtm_filtered <- dtm[non_empty_docs, ]

# IMPORTANT: subset article_data with same indices to keep alignment
article_data_filtered <- article_data[non_empty_docs, ]

# Assign dominant topic labels only for filtered documents
article_data_filtered$Dominant_Topic <- dominant_topic[non_empty_docs]

# Print a sample of article titles, their dominant topic and date published
print(head(article_data_filtered %>% dplyr::select(title, Dominant_Topic, date_published)))

# Save the labeled articles CSV
write_csv(article_data_filtered, paste0(output_dir, "BanglaTribune_articles_with_topics.csv"))
cat("Saved document topic labels to", paste0(output_dir, "BanglaTribune_articles_with_topics.csv"), "\n")


cat("\n=== Step 8: Stacked Bar Chart of Document Topics ===\n")

# Use the filtered data frame with Dominant_Topic column
topic_counts <- article_data_filtered %>%
  dplyr::group_by(Dominant_Topic) %>%
  dplyr::summarise(Count = n()) %>%
  dplyr::arrange(Dominant_Topic)

print(topic_counts)

# Create stacked bar chart plot
stacked_bar <- ggplot(topic_counts, aes(x = "", y = Count, fill = as.factor(Dominant_Topic))) +
  geom_bar(stat = "identity", width = 0.5) +
  labs(
    title = "Distribution of Documents by Dominant Topic",
    x = NULL, y = "Number of Documents", fill = "Topic"
  ) +
  scale_fill_brewer(palette = "Set2") +
  theme_minimal(base_family = ifelse("Nirmala UI" %in% windowsFonts(), "Nirmala UI", "Arial")) +
  theme(axis.text.x = element_blank())

# Show the plot in RStudio (opens a new window)
suppressWarnings({
  dev.new()
  print(stacked_bar)
})

# Save the plot as PNG
suppressWarnings({
  ggsave(
    filename = paste0(output_dir, "stacked_bar_topics.png"),
    plot = stacked_bar, width = 8, height = 6, units = "in"
  )
})
cat("Saved stacked_bar_topics.png to", output_dir, "\n")


# --- Step 9: Pie Chart of Document Topics ---
cat("\n=== Step 9: Pie Chart of Document Topics ===\n")

# Create pie chart plot
pie_chart <- ggplot(topic_counts, aes(x = "", y = Count, fill = as.factor(Dominant_Topic))) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  labs(title = "Proportion of Documents by Topic", fill = "Topic") +
  scale_fill_brewer(palette = "Set2") +
  theme_void(base_family = ifelse("Nirmala UI" %in% windowsFonts(), "Nirmala UI", "Arial"))

# Show the pie chart in RStudio (opens a new window)
suppressWarnings({
  dev.new()
  print(pie_chart)
})

# Save the pie chart as PNG
suppressWarnings({
  ggsave(
    filename = paste0(output_dir, "pie_chart_topics.png"),
    plot = pie_chart, width = 8, height = 6, units = "in"
  )
})
cat("Saved pie_chart_topics.png to", output_dir, "\n")

# Stop capturing console output
sink()
cat("\nAll console output saved to", console_output_file, "\n")





