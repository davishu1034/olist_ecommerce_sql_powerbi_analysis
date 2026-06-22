# Olist E-Commerce Analysis (2016–2018)

**Tools:** Google BigQuery · SQL · Power BI     
**Live Dashboard:** [View on Power BI](https://app.powerbi.com/view?r=eyJrIjoiNTY4ZjhmMDEtOTJjNy00YTFjLTk0ODItMTJmNmM3ZTNiOTQ2IiwidCI6ImM2ZTU0OWIzLTVmNDUtNDAzMi1hYWU5LWQ0MjQ0ZGM1YjJjNCJ9)

---


## Dataset
- **Source:** [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Period:** 2016–2018
- **Queried via:** Google BigQuery (GoogleSQL)

---

## Key Business Findings

| Metric | Value |
|---|---|
| Total Revenue | ₹15.42M |
| Total Orders | 96,478 |
| Avg Review Rating | 4.16 / 5 |
| Late Deliveries | 6,534 (6.86%) |
| On-Time Rate | 93.14% |
| Avg Delivery (overall) | 12 days |
| Avg Delivery (late orders) | 33 days — 2.75× above average |

**Peak late-delivery month:** March 2018 — 1,328 late orders (~20% of all late orders in 3 years)

---

## Dashboard Preview

<img width="1314" height="737" alt="dashboard_screenshot" src="https://github.com/user-attachments/assets/5eb9cb8d-cf1d-4f53-8862-c7910c0b551a" />

---

## Report
A professionally formatted PDF business intelligence report is available:  
[Download PDF Report](olist_bi_report.pdf)


---

## Analysis Areas

### 1. Late Delivery Analysis (`sql/late_delivery_analysis.sql`)
Investigated why 6,534 orders missed their estimated delivery date.
- Avg dispatch time before carrier handoff: **5 days**
- Avg in-transit time for late orders: **25 days** (vs 12 days overall)
- Root cause: dispatch delays + last-mile capacity issues in Q1 demand surges

### 2. Business Questions (`sql/business_questions.sql`)
Answered four core business questions:
- **Delivery by state** — avg delivery time per Brazilian state using TIMESTAMP_DIFF
- **Top revenue categories** — health & beauty (₹1.42M) and watches/gifts (₹1.27M) lead
- **Late delivery count** — 6,534 orders delivered after estimated date
- **6-month repeat purchase rate** — LAG() window function to identify returning customers

### 3. Seller Quality Ranking (in `sql/business_questions.sql`)
- Filtered to sellers with 50+ delivered orders
- Deduplicated reviews via CTE (some orders had multiple review entries)
- Ranked by avg review score to surface reliable marketplace partners

---

## SQL Techniques Used
- Window functions: `LAG()`, `AVG() OVER`
- CTEs (Common Table Expressions) for multi-step logic
- `TIMESTAMP_DIFF` for time-based calculations
- Multi-table JOINs (orders + customers + geo_location + products + payments)
- Conditional aggregation with `CASE WHEN`
