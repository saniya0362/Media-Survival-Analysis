# Media Survival Analysis – Bharat Herald

This project was completed as part of **Resume Project – Challenge 17 from Codebasics**. The objective was to analyze print circulation, advertising trends, and digital engagement for **Bharat Herald**, a legacy newspaper facing challenges such as declining readership, shifting consumption patterns, and growing competition. Using data analytics, the project provides insights into operational inefficiencies, advertising opportunities, and strategies for digital transformation.

---

## 📂 Project Structure

- **data-cleaning/** – Jupyter notebooks (.ipynb) used to clean and process raw datasets  
- **sql/** – SQL queries applied to answer business questions and extract structured insights 
- **docs/** -  Markdown files summarizing each report page with screenshots
- **Report/** – Link to the interactive Power BI Report for data visualization 
- **Presentation/** - Link to the Presentation

---

## ✅ Problem Statement

Between 2019 and 2024, Bharat Herald’s print circulation dropped by over **50%**, largely driven by increasing digital consumption, rising competition, and operational challenges. The organization needed a structured analysis to:  
- Quantify circulation and engagement trends  
- Identify areas for optimization and revenue growth  
- Recommend actionable steps for sustainable business expansion, especially in digital media

---

## ✅ Tools Used

- **Python & Pandas** – Data cleaning and transformation  
- **Power BI** – Interactive dashboards for data visualization  
- **MySQL** – Business intelligence queries and structured data analysis  
- **PowerPoint** – For presenting insights  

---

## 🔑 Key Insights & Observations

- ✔ Declining print circulation with a 25.15% year-over-year drop
- ✔ Jaipur Leads in Copies Sold and Net Circulation.
- ✔ Patna dominates advertising Revenue. 
- ✔ Waste optimization opportunities—Delhi, Ahmedabad, and Varanasi lead in returns.
- ✔ Lucknow takes the top spot for ROI.
- ✔ Kanpur leads in digital readiness.
- ✔ Government and Real Estate ads-categories are the strongest revenue drivers
- ✔ Lucknow, Patna, and Bhopal identified as priority cities for digital relaunch
- ✔ A phased digital transition roadmap for sustainable growth and advertiser trust recovery 

---

## 📌 Key Notes on Data & Methodology

> **Note 1:**  
> Print copies data is unavailable and cannot be calculated directly.  
> The formula "Print Copies = Copies Sold + Returned Copies" does not apply because in this dataset, "Copies Sold" reflects the sum of net circulation and returned copies (i.e., actual kiosk/vendor sales plus returns). Adding returned copies twice would overstate the print total.  
> The dataset lacks an "unsold copies" column, so true print volume cannot be reconstructed ([1][5]).

> **Note 2:**  
> Because printed copies data is unavailable, the actual efficiency ratio can't be calculated directly.  
> Instead, I use:  
> - Waste Ratio = Returned Copies / Copies Sold  
> - Efficiency Ratio = 100% - Waste Ratio  
> This provides a proxy for print efficiency and waste, based on available measures.

> **Note 3:**  
> The digital pilot dataset does not have a city identifier column.  
> To generate city-level granularity, I created a **city-category share** table using each city's share of ad revenue per category.  
> All digital pilot metrics were then multiplied by their respective city share to approximate city-wise digital engagement and usage.

---

## 📂 Files

- [Data Cleaning Scripts](data-cleaning.ipynb)  
- [SQL Queries](sql/Business Request.sql) 
- [Report Overview](docs/overview.md) 

---

## 📌 Dashboard

You can view the interactive Power BI dashboard [here](INSERT_DASHBOARD_LINK).

---

## 📌 Presentation

You can view the presentation [here](INSERT_PRESENTATION_LINK).

---

## 📌 GitHub Repository

Explore the code, datasets, and documentation to see how data-driven solutions address real-world challenges.

---

## 🙏 Acknowledgements  

Special thanks to **Codebasics** for practical challenges that empower learners to apply analytics to real business problems.
