# Hospital Cost Analysis

SQL analysis of healthcare insurance costs and key cost drivers.

## Project Overview

This project analyzes healthcare insurance costs to identify the demographic and behavioral factors associated with higher medical charges.

The analysis focuses on age, BMI, smoking status, number of children, region, and recorded sex category.

## Business Questions

This project aims to answer the following questions:

1. How are healthcare costs distributed across the dataset?
2. Which customer groups have the highest average healthcare costs?
3. How is smoking status associated with healthcare costs?
4. How do age and BMI relate to medical charges?
5. Which customer groups represent the highest cost risk?
6. What are the characteristics of the top 10% highest-cost individuals?

## Dataset

The dataset contains the following fields:

- `age`: Age of the individual
- `sex`: Recorded sex category
- `bmi`: Body mass index
- `children`: Number of dependent children
- `smoker`: Smoking status
- `region`: Geographic region
- `charges`: Healthcare insurance charges

## Project Structure

```text
hospital-cost-analysis/
├── data/
│   └── hospital_cost.csv
├── sql/
│   └── hospital_cost_analysis.sql
└── README.md