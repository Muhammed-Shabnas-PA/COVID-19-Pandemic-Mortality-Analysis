# 💀 COVID-19 Pandemic Mortality Analysis

This project presents a comprehensive data analysis of COVID-19 mortality trends across jurisdictions in the United States using **SQL Server** and **Power BI**.

It includes raw data cleaning, transformation, statistical queries, and insightful visualizations to help understand the pandemic's impact on various demographic and geographic groups.

---

## 📁 Project Structure

```
📂 COVID-19-Pandemic-Mortality-Analysis/
├── Pandemic Morality Trends.sql       # SQL queries for cleaning and analysis
├── Pandemic Morality Trends.pbix      # Power BI dashboard file
├── README.md                          # Project documentation (this file)
```

---

## 🎯 Objectives

- Clean and standardize COVID-19 death records using SQL
- Analyze trends in weekly deaths, death rates, and demographic patterns
- Visualize key insights using interactive Power BI dashboards
- Automate analysis using stored procedures and user-defined functions

---

## 🧩 Dataset Overview

The dataset used (`COVID_19_Death_Data`) includes:

- **Jurisdiction_Residence**: State or regional identity  
- **Group**: Demographic classification (age, gender, etc.)  
- **Time Periods**: Start and end dates for data aggregation  
- **Metrics**: COVID deaths, percentage of total deaths, crude and age-adjusted rates  
- **Weekly Changes**: Percentage differences over time  

---

## 🛠 SQL Tasks Performed

### 🔧 Data Cleaning & Type Conversion

- Converted columns to appropriate data types (`INT`, `DECIMAL`, `DATE`)
- Replaced empty strings with `NULL`
- Validated schema using `INFORMATION_SCHEMA.COLUMNS`

### 📊 Analytical Queries

1. **Top jurisdiction by total deaths (latest period)**
2. **Disparity between age-adjusted and crude death rates**
3. **Average weekly deaths per jurisdiction/group**
4. **Filtered analysis to exclude incomplete data**
5. **Week-over-week percentage changes in COVID death share**
6. **Cumulative deaths up to the latest period**
7. **Stored procedure + UDF for dynamic analysis**

### ⚙️ Procedure and Function

- **`fn_AvgCrudeCOVIDRate()`**: Returns average crude rate for a given jurisdiction
- **`sp_AvgWeeklyChangeInCOVIDDeaths()`**: Computes average weekly % change in deaths and compares with average crude rate

#### 📌 Example Procedure Call:

```sql
EXEC dbo.sp_AvgWeeklyChangeInCOVIDDeaths 
     @StartDate = '2022-01-01', 
     @EndDate = '2022-12-31';
```

---

## 📊 Power BI Dashboard

The Power BI report (`Pandemic Morality Trends.pbix`) presents:

### 🔍 Key Visuals

- Total COVID deaths (nationwide & filtered)
- Weekly trends of deaths and rates
- Choropleth maps of jurisdictions
- Demographic breakdowns (by group)
- Percentage change indicators
- Filterable slicers (by group, region, time)

📈 This combination empowered stakeholders to analyze patterns, track spikes, and explore disparities with just a few clicks.

---

## 🧠 Key Insights

- The **United States** had over **1.1 million deaths** as per the latest data.
- States like **Utah** and **Alaska** showed **significant disparities** between age-adjusted and crude rates.
- Some jurisdictions experienced **volatile weekly changes**, signaling pandemic waves.
- Missing or inconsistent data was **filtered** to ensure quality analysis.

![Dashboard Preview](dashboard.png)


---

## 📥 Getting Started

1. **Clone the repository**  
```bash
git clone https://github.com/Muhammed-Shabnas-PA/COVID-19-Pandemic-Mortality-Analysis.git
```

2. **Open SQL file in SSMS (SQL Server Management Studio)**  
   - Run each block step-by-step for cleaning, querying, and analysis

3. **Open `.pbix` file in Power BI Desktop**  
   - Explore filters, charts, maps, and key metrics

---

## 🚀 Future Enhancements

- Correlation with **vaccination rollout** and **hospitalization data**  
- Incorporate **predictive analytics** using Python or R  
- Publish Power BI dashboard to **Power BI Service** or web  

---

## 📌 Repository

🔗 [GitHub Repo](https://github.com/Muhammed-Shabnas-PA/COVID-19-Pandemic-Mortality-Analysis)

---

## 🙌 Credits

- **Author:** Muhammed Shabnas P A  
- **Tools Used:** SQL Server, Power BI  
- **Data Source:** Public health datasets (CSV format assumed; structure not disclosed)

---

## 📫 Contact

For questions, feedback, or collaboration opportunities:

📧 muhammedshabnaspa.com  
🔗 [LinkedIn Profile](www.linkedin.com/in/muhammed-shabnas-pa)

---

## 📝 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
