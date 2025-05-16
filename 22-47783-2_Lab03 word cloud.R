# Load required libraries
library(readr)
library(dplyr)
library(tm)
library(wordcloud)
library(RColorBrewer)

# Step 1: Read the CSV file
data <- read_csv("D:/IDS/code/dhakaTribune_articles_with_text.csv", show_col_types = FALSE)

# Step 2: Extract article_text column and combine all text into one string
text_data <- data$article_text
text_corpus <- paste(text_data, collapse = " ")

# Step 3: Create a corpus and clean the text
corpus <- Corpus(VectorSource(text_corpus))
corpus <- corpus %>%
  tm_map(content_transformer(tolower)) %>%
  tm_map(removePunctuation) %>%
  tm_map(removeNumbers) %>%
  tm_map(removeWords, stopwords("en")) %>%
  tm_map(stripWhitespace)

# Step 4: Create term-document matrix
tdm <- TermDocumentMatrix(corpus)
m <- as.matrix(tdm)
word_freqs <- sort(rowSums(m), decreasing = TRUE)
df <- data.frame(word = names(word_freqs), freq = word_freqs)

# Step 5: Draw the word cloud
set.seed(123)
# Save word cloud to a PNG file
png("D:/IDS/code/wordcloud.png", width = 1000, height = 800)
wordcloud(words = df$word,
          freq = df$freq,
          min.freq = 3,
          max.words = 100,
          random.order = FALSE,
          colors = brewer.pal(8, "Dark2"))
dev.off()

cat("✅ Word cloud saved to D:/IDS/code/ordcloud.png\n")
