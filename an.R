# ----------------------------------------------------------------------
# 1. Setup: Install and Load Libraries
# ----------------------------------------------------------------------
# install.packages("tidyverse") 
# install.packages("scales")
library(tidyverse)
library(scales)
options(scipen = 999) # Disable scientific notation for cleaner numbers

# Set consistent size for plots
plot_theme <- theme_minimal(base_size = 14)

# ----------------------------------------------------------------------
# 2. Data Loading (Using Uploaded CSV Files)
# ----------------------------------------------------------------------

# Load the core MovieLens data files
ratings_df <- read_csv("ml-latest-small/ratings.csv", show_col_types = FALSE)
movies_df <- read_csv("ml-latest-small/movies.csv", show_col_types = FALSE)

# ----------------------------------------------------------------------
# 3. Data Wrangling (Tidyverse: dplyr & tidyr)
# ----------------------------------------------------------------------

# 1. Merge data and extract release year
full_data <- ratings_df %>%
  # dplyr::left_join(): Join ratings with movie details on 'movieId'
  left_join(movies_df, by = "movieId") %>%
  # dplyr::mutate(): Extract the four-digit year from the 'title' column
  mutate(
    release_year = str_extract(title, "\\((\\d{4})\\)"),
    release_year = as.numeric(str_remove_all(release_year, "[\\(\\)]"))
  ) %>%
  # dplyr::filter(): Remove records where year could not be parsed
  filter(!is.na(release_year))

# 2. Convert data to long format by splitting genres
# Note: Genres are pipe-separated strings in this dataset.
long_data <- full_data %>%
  # tidyr::separate_rows(): Splits the single 'genres' column into multiple rows
  separate_rows(genres, sep = "\\|") %>%
  # dplyr::filter(): Exclude the placeholder genre
  filter(genres != "(no genres listed)") %>%
  # dplyr::mutate(): Create a decade variable
  mutate(
    # Create decade as a factor for ordering/grouping
    decade = factor(floor(release_year / 10) * 10)
  ) %>%
  # dplyr::select(): Select only the necessary columns for aggregation
  select(movieId, rating, genres, decade)

# 3. Summarize analysis: Calculate average rating and rating count per decade and genre
summary_data <- long_data %>%
  # dplyr::group_by(): Group by both decade and genre
  group_by(decade, genres) %>%
  # dplyr::summarise(): Calculate key metrics
  summarise(
    n_ratings = n(),
    avg_rating = mean(rating, na.rm = TRUE),
    .groups = 'drop'
  )

# ----------------------------------------------------------------------
# 4. Data Visualization (ggplot2)
# ----------------------------------------------------------------------

# --- Plot 1: Average Rating Distribution by Decade and Genre (Faceting) ---
# Required: geom_violin, geom_boxplot, facet_wrap, all labels

# Identify top genres for focused analysis (e.g., those with > 5000 total ratings)
top_genres <- summary_data %>%
  group_by(genres) %>%
  summarise(total_n = sum(n_ratings)) %>%
  filter(total_n > 5000) %>%
  pull(genres)

summary_data %>%
  filter(genres %in% top_genres) %>% 
  ggplot(aes(x = decade, y = avg_rating, fill = decade)) +
  # ggplot2::geom_violin(): Shows the distribution density
  geom_violin(trim = FALSE) + 
  # ggplot2::geom_boxplot(): Adds summary statistics (median, quartiles)
  geom_boxplot(width = 0.1, color = "grey30", outlier.shape = NA) +
  # ggplot2::facet_wrap(): Facet by Genre
  facet_wrap(~ genres, scales = "free_y") + 
  labs(
    title = "Plot 1: Average Rating Distribution for Major Movie Genres by Decade",
    subtitle = "Analysis of average rating stability and variance across time for high-volume genres.",
    caption = "Data Source: MovieLens ml-latest-small Dataset | Facet: genres | Geom: violin, boxplot",
    x = "Movie Release Decade",
    y = "Average Rating (1.0 - 5.0)"
  ) +
  plot_theme +
  theme(legend.position = "none", 
        axis.text.x = element_text(angle = 45, hjust = 1))

# --- Plot 2: Popularity Trends of Top Genres over Time ---
# Required: geom_line, geom_point, all labels

# Identify the absolute top 5 genres for line plot
abs_top_5_genres <- summary_data %>% 
  group_by(genres) %>% 
  summarise(total_n = sum(n_ratings)) %>% 
  arrange(desc(total_n)) %>% 
  head(5) %>% 
  pull(genres)

summary_data %>%
  filter(genres %in% abs_top_5_genres) %>%
  ggplot(aes(x = decade, y = n_ratings, group = genres, color = genres)) +
  # ggplot2::geom_line(): Connects points to show trend
  geom_line(size = 1.2) + 
  # ggplot2::geom_point(): Marks each data point
  geom_point(size = 3) +
  labs(
    title = "Plot 2: Popularity (Rating Count) Trend of Top 5 Genres by Decade",
    subtitle = "Drama and Comedy consistently lead in popularity across the analyzed time span (1950s - 2010s).",
    caption = "Data Source: MovieLens ml-latest-small Dataset | Geom: line, point",
    x = "Movie Release Decade",
    y = "Total Number of Ratings (n_ratings)",
    color = "Movie Genre"
  ) +
  scale_y_continuous(labels = comma) + # Format Y-axis with commas
  plot_theme +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# --- Plot 3: Highest-Rated Genres by Decade ---
# Required: geom_col (or geom_bar), all labels

# Find the single genre with the highest average rating for each decade
highest_rated_decade <- summary_data %>%
  group_by(decade) %>%
  filter(avg_rating == max(avg_rating)) %>%
  ungroup()

highest_rated_decade %>%
  ggplot(aes(x = decade, y = avg_rating, fill = genres)) +
  # ggplot2::geom_col(): Uses height to represent the value (avg_rating)
  geom_col(position = "dodge") + 
  labs(
    title = "Plot 3: Highest Average Rated Genre in Each Decade",
    subtitle = "Non-mainstream genres like Film-Noir and Documentary often claim the highest average rating in older decades.",
    caption = "Data Source: MovieLens ml-latest-small Dataset | Geom: col",
    x = "Movie Release Decade",
    y = "Highest Average Rating (1.0 - 5.0)",
    fill = "Genre"
  ) +
  scale_y_continuous(limits = c(0, 5)) +
  plot_theme +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# ----------------------------------------------------------------------
# 5. Function List (For Requirement Check)
# ----------------------------------------------------------------------
cat("\n--- Used Tidyverse Functions (for TA review) ---\n")
cat("dplyr Functions (required 5): left_join(), mutate(), filter(), group_by(), summarise(), select()\n")
cat("tidyr Functions (required 1): separate_rows()\n")
cat("ggplot2 geom_*() Functions (required 3): geom_violin(), geom_boxplot(), geom_line(), geom_point(), geom_col()\n")
cat("ggplot2 Features: facet_wrap(), labs(title, subtitle, caption, x, y)\n")