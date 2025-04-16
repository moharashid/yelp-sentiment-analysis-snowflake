# Yelp Sentiment Analysis with Python, Snowflake & SQL

This is an end-to-end data analytics project where we analyze Yelp reviews using a combination of **Python**, **Snowflake**, and **SQL**. The project demonstrates a complete workflow—from handling raw JSON data to generating meaningful business insights using sentiment analysis and SQL queries.

---

## Project Workflow

### Step 1: Data Preprocessing (Python)
- The original Yelp dataset is a large JSON file.
- We use Python to **split the large JSON into smaller chunks** to improve performance during upload.
- These chunks are then saved locally and uploaded to **AWS S3**.

### Step 2: Cloud Storage & Ingestion (Snowflake)
- Snowflake is used as the data warehouse.
- JSON data is ingested from S3 into Snowflake using the `COPY INTO` command.
- We define tables using Snowflake's `VARIANT` type and then extract relevant fields into structured tables.

### Step 3: Sentiment Analysis (Python UDF in Snowflake)
- We use the `textblob` library via **Python UDFs inside Snowflake** to:
  - Calculate the **sentiment polarity score**
  - Categorize sentiment as `Positive`, `Negative`, or `Neutral`
  
### Step 4: SQL-Based Analytics
- We answer **10+ business questions** using SQL, including:
  - Most common business categories
  - Top reviewers in restaurant-related businesses
  - 5-star review trends by category
  - Sentiment-based ranking of businesses
  - Monthly review volumes and more

---

## Technologies Used

- **Python 3**
  - TextBlob
  - JSON parsing
- **Snowflake**
  - Variant data type
  - Python UDFs
  - SQL analytics
- **AWS S3**
  - Storage for the split JSON files

