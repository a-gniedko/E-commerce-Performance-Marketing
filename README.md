# **📊 E-commerce Performance & Marketing Analytics**
An end-to-end e-commerce analytics project using MySQL and Power BI to analyze sales performance, conversion funnels, marketing effectiveness, device behavior, customer retention, and product category performance.

## 🖼️ Dashboard Preview
> Interactive Power BI dashboards — click any image to open it full-size.

| **Executive Summary** | **Funnel Analysis** |
|:---:|:---:|
| [![Executive Summary](screenshots/1.Executive%20Summary.jpg)](screenshots/1.Executive%20Summary.jpg) | [![Funnel Analysis](screenshots/2.Funnel%20Analysis.jpg)](screenshots/2.Funnel%20Analysis.jpg) |
| **Marketing Performance** | **Device & Checkout Analysis** |
| [![Marketing Performance](screenshots/3.Marketing%20Performance.jpg)](screenshots/3.Marketing%20Performance.jpg) | [![Device & Checkout Analysis](screenshots/4.Device%26Checkout%20Analysis.jpg)](screenshots/4.Device%26Checkout%20Analysis.jpg) |
| **Orders & Revenue** | **Recommendations** |
| [![Orders & Revenue](screenshots/5.Orders%26Revenue.jpg)](screenshots/5.Orders%26Revenue.jpg) | [![Recommendations](screenshots/6.%20Recommeddations.jpg)](screenshots/6.%20Recommeddations.jpg) |

## 🎯 Project Overview
The goal of this project was to understand why increasing website traffic does not necessarily translate into proportional growth in sales and revenue.
Using SQL for data analysis and Power BI for interactive reporting, the project identifies conversion bottlenecks, evaluates marketing channel and campaign performance, investigates mobile checkout issues, and analyzes repeat purchasing behavior.

The data used in this project is educational and intended for portfolio and analytical purposes.

## 🔍 Key Business Questions
-	How does website traffic change over time?
-	Where are the largest drop-offs in the purchase funnel?
-	Which marketing channels and campaigns generate the strongest results?
-	How does conversion differ across devices?
-	What may explain the decline in mobile checkout conversion?
-	How do repeat customers contribute to revenue?
-	Which product categories generate the most revenue, and where are cancellation and refund rates highest?
## 📈 Key Findings
-	**Conversion funnel:** Overall session-to-purchase conversion is 9.18%. The largest funnel drop occurs between product views and add-to-cart actions, with a conversion rate of 30.02%.
-	**Marketing performance:** Email has the highest conversion rate (13.63%) and ROAS (4.51) among the analyzed channels.
-	**Mobile performance:** Mobile conversion is 7.89%, compared with 11.49% on Desktop and 11.15% on Tablet.
-	**Checkout analysis:** Mobile checkout v2 has a lower checkout-to-purchase conversion rate than Standard (38.14% vs. 66.39%). This is a potential issue for further investigation, not proof of causation.
-	**Customer retention:** 119 of 486 customers with at least one successful purchase made more than one successful purchase. The repeat purchase rate is 24.49%.
-	**Product categories:** Fashion generates the highest merchandise revenue (€31,016.19), while Beauty has the highest cancellation and refund rate.
## 🖥️ Power BI Dashboard Pages
The report is organized into dedicated pages:
1.	Executive Summary — Overall KPIs, monthly performance, conversion funnel, and key business insights.
2.  Funnel Analysis — Conversion rates and drop-offs across the purchase journey.
3.	Marketing Performance — Marketing spend, revenue, ROAS, channel comparisons, and campaign performance.
4.	Device & Checkout Analysis — Conversion by device, mobile funnel trends, and checkout version comparison.
5.	Orders & Revenue — Gross and net revenue, order trends, average order value, category performance, and order status.
6.	Recommendations — Actionable recommendations based on the analytical findings.


## 🗄️ Dataset & Data Preparation

This project uses educational e-commerce data for portfolio and analytical purposes. MySQL was used for database creation, data quality checks, and SQL analysis, while Power BI was used to build an interactive dashboard suite and visualize key business metrics. The dataset includes sessions, user behavior, orders, order items, products, marketing campaigns, advertising spend, and calendar data, organized into fact and dimension tables.

The data preparation workflow followed these steps:

1. **Database Setup:** Created the MySQL database and imported the source tables.
2. **Data Quality Checks:** Checked table structure, data consistency, missing values, and duplicates.
3. **SQL Analysis:** Prepared and analyzed data for traffic, conversion funnels, marketing performance, devices, orders, revenue, and repeat purchases.
4. **Power BI Integration:** Connected the data to Power BI, configured relationships between fact and dimension tables, and developed interactive dashboards.

Revenue calculations accounted for the relationship between orders and order items to avoid double counting.
   
## 🛠️ Tools & Techniques
-	**MySQL / SQL:** Data quality checks, joins, aggregations, CTEs, conditional logic, and business metric calculations
-	**Power BI:** Interactive dashboards, KPI cards, slicers, and comparative visualizations
-	**DAX:** Measures for conversion rates, revenue, average order value, marketing spend, and ROAS
-	**Data Modeling:** Relationships between fact and dimension tables
-	**Business Analysis:** Funnel optimization, campaign evaluation, mobile checkout investigation, and customer retention
## 💡 Recommendations
- **Improve Conversion:** Optimize product pages, calls to action, product information, and purchase visibility to increase add-to-cart conversion.
- **Investigate Mobile Checkout:** Examine the mobile checkout v2 experience and test it against the Standard version before deciding on further changes.
- **Optimize Marketing Spend:** Evaluate channels using ROAS, conversion rate, and revenue per session rather than traffic volume alone.
- **Review Campaign Performance:** Investigate targeting, creatives, and audiences for campaigns with substantial spend but weak results.
- **Strengthen Retention:** Use email follow-ups, abandoned-cart reminders, and targeted offers to encourage repeat purchases.
- **Analyze Product Categories:** Investigate cancellation and refund patterns in Beauty and use category-level performance to inform assortment decisions.
## 📌 Conclusion
The analysis shows that traffic growth alone is not sufficient to improve e-commerce performance. The main opportunities lie in improving product-view-to-cart conversion, investigating lower mobile checkout performance, optimizing marketing spend, and increasing repeat purchases.

## 👩‍💻 Author
**Anna Gniedko**
- 📧 as.gnedko@gmail.com
- [<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/linkedin/linkedin-original.svg" width="22" height="22" alt="LinkedIn" /> LinkedIn](https://www.linkedin.com/in/anna-gniedko/)


