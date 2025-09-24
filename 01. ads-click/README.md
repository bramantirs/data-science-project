# Ad Click Prediction - Data Cleaning & EDA

This repository contains data preparation and exploratory data analysis (EDA) for the [Ad Click Prediction Dataset](https://www.kaggle.com/datasets/marius2303/ad-click-prediction-dataset/data).

## 📂 Dataset
The dataset provides user demographics, browsing behavior, ad placement details, and whether the user clicked on an ad.  
It is ideal for building binary classification models to predict user interaction with ads.

### Features
- **id**: Unique identifier for each user  
- **full_name**: User name (anonymized as "UserX")  
- **age**: User age (18–64)  
- **gender**: Male, Female, or Non-Binary  
- **device_type**: Mobile, Desktop, Tablet  
- **ad_position**: Top, Side, Bottom  
- **browsing_history**: User browsing activity before the ad (Shopping, News, Entertainment, Education, Social Media)  
- **time_of_day**: Morning, Afternoon, Evening, Night  
- **click**: Target label (1 = Click, 0 = No Click)

---

## 🧹 Data Cleaning Steps
1. **Handle missing values**
   - Filled missing `age` by imputing per `id` when possible.
   - Filled missing `gender`, `device_type`, `ad_position`, `browsing_history`, and `time_of_day` with their **mode**.
2. **Removed duplicates**
   - Dropped rows that are completely identical across all columns.
3. **Ensured correct data types**
   - Converted `age` to numeric.
   - Ensured `click` is integer (binary).
4. **Indexed data**
   - Added indexes on `id` for faster joins and batch updates.

---

## 📊 Target Distribution (Imbalanced Data)

| Click | Count | Percentage |
|------|-------|------------|
| **1** (Clicked) | 500 | **12.50%** |
| **0** (Not Clicked) | 3500 | **87.50%** |
| **Total** | 4000 | 100% |

> ⚠️ **Observation:**  
> The dataset is highly imbalanced — only 12.5% of users clicked on an ad.  
> This means accuracy is not a good performance metric for modeling.  
> Metrics like **Precision, Recall, F1-score, and ROC-AUC** will be more informative.

---

## 📊 Exploratory Data Analysis (EDA)

### 1. Click-Through Rate (CTR)
CTR was calculated as:

\[
CTR = (Number of Clicks ÷ Total Impressions) × 100
\]

Example result by **Device × Time of Day**:

| Device × Time | Total | Clicks | CTR (%) |
|---------------|-------|--------|---------|
| Desktop Afternoon | 346 | 47 | 13.58 |
| Desktop Morning | 685 | 43 | 6.28 |
| Mobile Afternoon | 198 | 42 | **21.21** |
| Tablet Evening | 241 | 45 | 18.67 |
| ... | ... | ... | ... |

**Insights:**
- **Mobile Afternoon** has the highest CTR (21.21%) => users are more likely to engage during the afternoon on mobile devices.
- Desktop Morning has the lowest CTR (6.28%) => possibly users are busy working and less likely to click.
- Tablets generally perform better than desktops in terms of CTR.

---

### 2. Age Distribution per Click Class

| Click | Mean Age | Min | Max |
|------|-----------|-----|-----|
| 1 (Click) | 40 | 18 | 64 |
| 0 (No Click) | 41 | 18 | 64 |

**Insight:**  
The age distribution is very similar for clicked vs. not-clicked users, meaning **age is not a strong predictor** for ad click likelihood.

---

## 📝 Key Takeaways
- **Data Quality:** Missing values were successfully imputed, and duplicate rows removed.
- **Target Imbalance:** Only **12.5%** of the rows represent ad clicks, this is an imbalanced dataset and will require techniques like resampling or class-weight adjustment during modeling.
- **Behavioral Insights:**
  - CTR is highest on mobile devices, especially during the afternoon.
  - Desktop users have the lowest CTR in the morning.
  - Age does not seem to significantly affect click behavior.

---

## 🎯 Next Steps
- Feature engineering (e.g., binary features for time-of-day groupings).
- Build classification models to predict `click`.
- Handle class imbalance with SMOTE, oversampling, or model-based class weights.

---

