
# Osteoporosis Model Explorer

An interactive research demo for exploring machine learning-based osteoporosis risk predictions across eight outcomes.

## The Problem

Osteoporosis and low bone density can go undetected until significant bone loss or fractures occur. Machine learning models offer a potential approach to identifying individuals at risk using patient characteristics.

However, running and comparing multiple predictive models often requires familiarity with programming environments and statistical tools. This project aims to make model predictions more accessible through a simple web interface.

## MVP Scope

**Target completion: November 29, 2026**

The minimum viable product (MVP) focuses on connecting trained logistic regression models to a simple interface for generating and interpreting predictions.

### Core Features

- **Model integration:** Fit and save logistic regression (LR) models for eight prediction outcomes.
- **Patient inputs:** Collect four inputs:
  - Age
  - Height
  - Weight
  - Age at menopause
- **BMI calculation:** Calculate body mass index (BMI) from the user's height and weight.
- **Prediction API:** Build an R Plumber `/predict` endpoint to receive inputs and return predictions.
- **User interface:** Provide a simple webpage for entering patient characteristics and viewing results.
- **Prediction results:** Use JavaScript `fetch` requests to communicate with the backend and display predictions in a results table.
- **Input validation:** Check user inputs and provide understandable error messages.
- **Interpretability:** Include plain-language explanations of predictions, model limitations, and a research-demo-only disclaimer.

### MVP Quality and Documentation

- Correct the osteopenia classification rule and T-score typo.
- Fix model overwriting issues.
- Test the application from a fresh repository clone.
- Document the architecture with a diagram.
- Provide a short demonstration video.

## How It Works

*Implementation in progress.*

Users enter their age, height, weight, and age at menopause through the web interface. The application calculates BMI from height and weight and sends the patient information to an R Plumber API. The backend processes the inputs, runs the appropriate logistic regression models, and returns prediction results for display.

## Tech Stack

- **Frontend:** JavaScript, HTML/CSS (React/Vite scaffold currently initialized; final MVP framework to be determined)
- **Backend:** R, Plumber
- **Machine Learning:** Logistic Regression, R, Python, scikit-learn
- **Version Control:** Git, GitHub

## Roadmap

### Future Work

*Planned after November 29, 2026.*

- [ ] Add one additional feature for the assignment on a separate branch:
  - Screening-cutoff flag indicating when to consider DXA, or
  - A small model performance comparison table.
- [ ] Build a comprehensive model performance page with AUC confidence intervals, calibration, and Brier scores.
- [ ] Address data leakage by splitting data before preprocessing and calculating imputation means using training data only.
- [ ] Explore adding a `has_menopause` flag.
- [ ] Explore cross-validation-based hyperparameter tuning.
- [ ] Evaluate additional algorithms individually:
  - Random Forest
  - LASSO
  - XGBoost
  - Neural Networks
  - K-Nearest Neighbors (KNN)
- [ ] Compare predictions against OSTA for research purposes.

### Out of Scope

- User accounts and database infrastructure.
- Deployment and hosting.
- Unnecessary frontend complexity or frameworks if plain HTML/JavaScript is sufficient.
- Algorithms that cannot be adequately explained or justified.

## Demo

*Coming soon.*
