# **📊 E-commerce Performance & Marketing Analytics**
An end-to-end e-commerce analytics project combining SQL analysis and interactive Power BI dashboards to evaluate sales performance, conversion funnels, marketing effectiveness, device behavior, customer retention, and product category performance.
**Tools:** SQL · Power BI · DAX · Data Modeling · Data Visualization
## 🎯 Project Overview
The goal of this project was to understand why increasing website traffic does not necessarily translate into proportional growth in sales and revenue.
Using SQL for data exploration and business analysis and Power BI for interactive reporting, the project identifies conversion bottlenecks, compares marketing channel and campaign performance, investigates mobile checkout issues, and evaluates repeat purchasing behavior.
## 🔍 Key Business Questions
-	How does website traffic change over time?
-	Where are the largest drop-offs in the purchase funnel?
-	Which marketing channels and campaigns generate the strongest results?
-	How does conversion differ across devices?
-	Is mobile checkout performance affecting purchases?
-	How do repeat customers contribute to revenue?
-	Which product categories generate the most revenue, and where are cancellation and refund rates highest?
## 📈 Key Findings
-	Conversion funnel: Overall session-to-purchase conversion is 9.18%. The largest funnel drop occurs between product views and add-to-cart actions, with a conversion rate of 30.02%.
-	Marketing performance: Email has the highest conversion rate (13.63%) and ROAS (4.51) among the analyzed channels.
-	Mobile performance: Mobile conversion is 7.89%, compared with 11.49% on Desktop and 11.15% on Tablet.
-	Checkout analysis: Mobile checkout v2 has a lower checkout-to-purchase conversion rate than Standard (38.14% vs. 68.79%). This is a potential issue for further investigation, not proof of causation.
-	Customer retention: 119 of 486 customers with at least one successful purchase made more than one successful purchase, resulting in a repeat purchase rate of 24.49%.
-	Product categories: Fashion generates the highest merchandise revenue (€31,016.19), while Beauty has the highest cancellation and refund rate.
## 🖥️ Power BI Dashboard Pages
The report is organized into dedicated pages:
1.	Executive Summary — Overall KPIs, monthly performance, conversion funnel, and key business insights.
2.	Marketing Performance — Marketing spend, revenue, ROAS, channel comparisons, and campaign performance.
3.	Device & Checkout Analysis — Conversion by device, mobile funnel trends, and checkout version comparison.
4.	Orders & Revenue — Gross and net revenue, order trends, average order value, category performance, and order status.
5.	Customer Retention — Repeat purchasing behavior and customer segment analysis.
6.	Recommendations — Actionable recommendations based on the analytical findings.
## 🖼️ Dashboard Preview
> Interactive Power BI dashboards — click any image to open it full-size.
| **Executive Summary** | **Funnel Analysis** |
|:---:|:---:|
| [![Executive Summary](screenshots/1.Executive%20Summary.jpg)](screenshots/1.Executive%20Summary.jpg) | [![Funnel Analysis](screenshots/2.Funnel%20Analysis.jpg)](screenshots/2.Funnel%20Analysis.jpg) |
| **Marketing Performance** | **Device & Checkout Analysis** |
| [![Marketing Performance](screenshots/3.Marketing%20Performance.jpg)](screenshots/3.Marketing%20Performance.jpg) | [![Device & Checkout Analysis](screenshots/4.Device%26Checkout%20Analysis.jpg)](screenshots/4.Device%26Checkout%20Analysis.jpg) |
| **Orders & Revenue** | **Recommendations** |
| [![Orders & Revenue](screenshots/5.Orders%26Revenue.jpg)](screenshots/5.Orders%26Revenue.jpg) | [![Recommendations](screenshots/6.%20Recommeddations.jpg)](screenshots/6.%20Recommeddations.jpg) |


## 🧮 SQL Analysis
SQL was used to prepare and validate the data and investigate business performance through a series of analytical steps:
-	Database creation and data quality checks
-	Traffic and session analysis
-	Purchase funnel analysis
-	Marketing channel and campaign performance
-	Device conversion analysis
-	Orders and revenue analysis
-	Repeat purchase analysis
Revenue calculations accounted for the relationship between orders and order items to avoid double counting.
## 🛠️ Tools & Techniques
-	SQL: Data quality checks, joins, aggregations, CTEs, conditional logic, and business metric calculations
-	Power BI: Interactive dashboards, KPI cards, slicers, and comparative visualizations
-	DAX: Measures for conversion rates, revenue, average order value, marketing spend, and ROAS
-	Data Modeling: Relationships between fact and dimension tables
-	Business Analysis: Funnel optimization, campaign evaluation, mobile checkout investigation, and customer retention
## 💡 Recommendations
The analysis highlights several opportunities to improve e-commerce performance:
-	Improve product pages and calls to action to increase add-to-cart conversion.
-	Investigate the mobile checkout v2 experience and validate potential friction points.
-	Evaluate marketing investments using ROAS, conversion, and revenue per session rather than traffic volume alone.
-	Review underperforming campaigns.
-	Strengthen customer retention through email follow-ups and abandoned-cart reminders.
-	Investigate cancellation and refund patterns in the Beauty category.
## 📌 Conclusion
The project demonstrates how SQL and Power BI can be combined to turn raw e-commerce data into actionable business insights. The analysis identifies opportunities to improve conversion, evaluate marketing efficiency, investigate mobile checkout performance, and strengthen customer retention.
## 🧰 Technologies
SQL · Power BI Desktop · DAX · Data Modeling · Data Analysis · Data Visualization
## 👩‍💻 Author
**Anna Gniedko**
- 📧 as.gnedko@gmail.com
- [<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/linkedin/linkedin-original.svg" width="22" height="22" alt="LinkedIn" /> LinkedIn](https://www.linkedin.com/in/anna-gniedko/)


