--First create a database on Snowflake
use database MY_PROJECTS
create or replace table yelp_review(review_text variant)
--Copy reviews data from S3 to snowflake
copy into yelp_review
from 's3://my-yelp-review-bucket/'
CREDENTIALS = (
    AWS_KEY_ID = '' --enter your user credential keys to access AWS S3 bucket, keep it a secret and do not share it with anyone
    AWS_SECRET_KEY = '' --enter your user credential keys to access AWS S3 bucket, keep it a secret and do not share it with anyone
    
)
FILE_FORMAT= (TYPE=JSON)
--Copy business info data from S3 to snowflake
create or replace table yelp_businesses(businesses_text variant)
copy into yelp_businesses
from 's3://my-yelp-review-bucket/yelp-businesses/'
CREDENTIALS = (
    AWS_KEY_ID = '' --enter your user credential keys to access AWS S3 bucket, keep it a secret and do not share it with anyone
    AWS_SECRET_KEY = '' --enter your user credential keys to access AWS S3 bucket, keep it a secret and do not share it with anyone
    
)
FILE_FORMAT= (TYPE=JSON)

--Sample overview of the data
select * from yelp_review limit 10;
create table tbl_reviews as
    select  
        review_text:business_id::string as business_id,
        review_text:date::date as review_date,
        review_text:stars::number as review_stars,
        review_text:text::string as review_text
    from yelp_review

select count(*) from tbl_reviews
select * from tbl_reviews limit 10
--UDF function to perform sentimental analysis
CREATE OR REPLACE FUNCTION sentiment_polarity(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('textblob') 
HANDLER = 'sentiment_analyzer'
AS $$
import math
from textblob import TextBlob
def sentiment_analyzer(text):
    analysis = TextBlob(text)
    return round(analysis.sentiment.polarity,5)

$$;
CREATE OR REPLACE FUNCTION sentiment_analyzer(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('textblob') 
HANDLER = 'sentiment_analyzer'
AS $$
from textblob import TextBlob
def sentiment_analyzer(text):
    analysis = TextBlob(text)
    if analysis.sentiment.polarity > 0:
        return 'Positive'
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'

$$;
--create a reviews table
create or replace table tbl_reviews as 
    select  review_text:business_id::string as business_id 
    ,review_text:date::date as review_date 
    ,review_text:user_id::string as user_id
    ,review_text:stars::number as review_stars
    ,review_text:text::string as review_text
    ,sentiment_polarity(review_text) as polarity
    ,sentiment_analyzer(review_text) as sentiment
    
    from yelp_review
select * from tbl_reviews limit 100
select count(*) from tbl_reviews
select * from yelp_businesses limit 10

--Create a business table
create or replace table tbl_yelp_businesses as 
select businesses_text:business_id::string as business_id
,businesses_text:name::string as name
,businesses_text:city::string as city
,businesses_text:state::string as state
,businesses_text:review_count::number as review_count
,businesses_text:stars::number as stars
,businesses_text:categories::string as categories
from yelp_businesses limit 100
select * from tbl_yelp_businesses
