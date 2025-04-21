
# Customer Segmentation for Strategic Marketing Optimization

## Executive Summary

This report presents a comprehensive analysis of Sprocket Central’s customer portfolio, an Australian company specializing in bicycles and parts. The analysis leverages data from the `transactions`, `customer_demographic`, `customer_address`, and `new_customer_list` tables, utilized RFM (Recency, Frequency, Monetary) analysis to identify high-value customer segments and target 1,000 new prospects. The most profitable segments ("best customer," "active loyal customer," and "customer") are aged 35–44, located in New South Wales, work in Health, Manufacturing, or Financial Services, and belong to the Mass Customer wealth segment. They prefer the Solex brand, maintain an average purchase value of ~$1,100, and show consistent sales with slight peaks in April, August, October, and holiday-driven surges in November and December. A curated list of new customers matching these traits was developed to optimize marketing, enhance retention, and drive revenue growth.

## Problem Statement

Sprocket Central seeks to optimize its marketing efforts by identifying target customers from a list of 1,000 new prospects. The objectives are to:

- Identify profitable customer segments from the existing customer base.
- Understand the demographic and behavioral characteristics of these segments.
- Identify new customers with similar traits for targeted marketing.

## Customer Segmentation

Customer segmentation involves dividing a customer base into groups with similar characteristics relevant to marketing, such as demographics, behaviors, or preferences. The purpose is to enhance marketing effectiveness, improve customer satisfaction, and drive business performance by tailoring strategies to specific groups.

## RFM Analysis

RFM (Recency, Frequency, Monetary) analysis is a method for segmenting customers based on past purchasing behavior:

- **Recency (R)**: Measures how recently a customer made a purchase. Recent purchasers are typically more engaged and responsive.
- **Frequency (F)**: Counts how often a customer purchases. Frequent buyers are often loyal and valuable.
- **Monetary Value (M)**: Reflects total customer spend. Higher spenders are generally more profitable.

Each metric was scored on a 1–4 scale, with 4 indicating the best performance (low recency, high frequency, high monetary value). These scores were combined to form an `rfm_score` (e.g., "444" for top performers), resulting in 10 distinct customer segments. Higher-scoring segments are more profitable, characterized by recent purchases, frequent transactions, and high spending.

## Conceptual Analytical Approach

The analysis followed a structured, data-driven methodology to derive actionable insights:

1. **Data Profiling**: Explored the `transactions`, `customer_demographic`, `customer_address`, and `new_customer_list` datasets to assess structure, temporal scope, geographic distribution, and customer counts, ensuring a robust foundation.
2. **RFM Analysis**: Applied the RFM framework to quantify customer engagement and value, scoring customers on recency, frequency, and monetary metrics to enable segmentation.
3. **Customer Segmentation**: Categorized customers into segments (e.g., "best customer," "active loyal customer") based on RFM scores, identifying high-value groups for targeted strategies.
4. **Targeted Segment Analysis and New Customer Identification**: Analyzed high-value segments ("best customer," "active loyal customer," and "customer") for demographic (e.g., age, location) and behavioral (e.g., brand preferences) characteristics, and identified new customers with matching traits for acquisition.

This approach combined quantitative rigor with business relevance, using SQL-based analytics to transform raw data into strategic insights.

## Methodology

The analysis was executed in three phases:

1. **Identifying Profitable Customer Segments**: Used RFM analysis to segment existing customers and pinpoint high-value groups.
2. **Understanding Target Segments**: Analyzed demographics (age, location, job industry) and preferences (brand, product line, seasonal trends) of target segments.
3. **Identifying New Customers**: Selected prospective customers from the `new_customer_list` with traits similar to high-value segments.



# Findings
Based on the RFM (Recency, Frequency, Monetary) analysis, the most profitable customers exhibit the following demographics and purchasing preferences:

### Demographics:
- **Age Group**: 35-44
- **Location**: New South Wales
- **Industry**: Health, Manufacturing, Financial Services
- **Wealth Segment**: Mass Market Customers

### Purchasing Preferences:
- **Brand Preference**: A strong preference for the Solex brand was observed among profitable customers.
- **Sales Trends**: Sales remain relatively consistent throughout the year, with slight increases in April, August, and October, followed by seasonal peaks in November and December due to holiday demand.
- **Average Sales Price**: The average sales price is approximately **$1,100**, indicating a steady pricing preference among this customer group.
