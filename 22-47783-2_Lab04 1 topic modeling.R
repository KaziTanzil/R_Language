# Essential libraries only

library(tm)

library(topicmodels)

library(readr)

# Load data

data <- read_csv("D:/IDS/code/dhakaTribune_articles_with_text.csv", show_col_types = FALSE)

text_data <- data$article_text

# Use VCorpus instead of SimpleCorpus

corpus <- VCorpus(VectorSource(text_data))

# Custom stopwords

custom_stopwords <- c("said", "year", "will", "bangladesh", "s", "go", "told", "al", 
                      
                      "jazeera", '"', "t", "sat", "hasn", "also", "many", "says")

# Preprocess the text

corpus <- tm_map(corpus, content_transformer(tolower))    

corpus <- tm_map(corpus, content_transformer(function(x) gsub("[^a-z ]", " ", x))) 

corpus <- tm_map(corpus, removePunctuation)                 

corpus <- tm_map(corpus, removeNumbers)                   

corpus <- tm_map(corpus, removeWords, stopwords("english")) 

corpus <- tm_map(corpus, removeWords, custom_stopwords)     

corpus <- tm_map(corpus, stripWhitespace)                 

# Remove empty documents

corpus <- corpus[which(sapply(corpus, function(x) {
  
  text <- as.character(x$content)
  
  nchar(gsub(" ", "", text)) > 0
  
}))]

# Create Document-Term Matrix

dtm <- DocumentTermMatrix(corpus)

# Remove empty rows

dtm <- dtm[apply(dtm, 1, sum) > 0, ]

# Topic Modeling using LDA

num_topics <- 6

lda_model <- LDA(dtm, k = num_topics, control = list(seed = 42))

top_terms <- terms(lda_model, 10)

# Output top terms for each topic

cat("Top Terms for Each Topic:\n")

print(top_terms)

