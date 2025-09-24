# 🖱️ Ad Click Prediction – Data Cleaning & EDA

This project focuses on **cleaning, exploring, and preparing** the [Ad Click Prediction Dataset](https://www.kaggle.com/datasets/marius2303/ad-click-prediction-dataset/data) for machine learning.  
The dataset provides valuable insights into user demographics, browsing behavior, and online advertisement interactions.

--

## 🎯 Goal
The objective of this project is to **predict whether a user will click on an online advertisement** based on:
- Demographic data (`age`, `gender`)
- Browsing behavior (`browsing_history`)
- Context of ad display (`device_type`, `ad_position`, `time_of_day`)

This data can help:
- Improve **ad targeting strategies**
- Optimize **ad placement**
- Better understand **user interaction** with online advertisements

---

## 🧹 Data Cleaning Steps
The dataset contained **missing values, duplicates, and inconsistencies** that were addressed systematically using SQL:

1. **Handled Missing Values**
   - Filled `age` per user `id` using existing known values.
   - For `id` with no age information at all, imputed with dataset mean age.
   - Filled categorical columns (`gender`, `device_type`, `ad_position`, `browsing_history`, `time_of_day`) using their **mode**.

2. **Removed Duplicates**
   - Deleted rows with identical values across all columns to prevent data leakage and overfitting.

3. **Standardized Data Types**
   - Converted `age` to numeric type for proper statistical analysis.
   - Ensured categorical variables use consistent formatting.
