-- Analysis queries for Risk Monitoring Analytics Project
-- All queries are tied to specific risk questions.
-- Continuing to use Copilot for this. Will save prompt/reponse in OneNote. Currently copilot is writing the queries and explaining each line.

-- Q1: What does a sample of transactions look like?
-- Goal: Get familiar with the columns and values.

SELECT
transaction_id,
customer_id,
amount,
is_fraud
FROM creditcard_fraud_synthetic_small
LIMIT 10;

-- Q2: How many transactions are in the dataset?
-- Goal: Understand dataset size for analysis and performance.

SELECT
    COUNT(*) AS total_transactions
FROM creditcard_fraud_synthetic;

-- Q3: How many transactions are fraud vs non-fraud?
-- Goal: Get a basic fraud rate and class balance.

SELECT
    is_fraud,
    COUNT(*) AS transaction_count
FROM creditcard_fraud_synthetic
GROUP BY
    is_fraud;

-- Q4: What is the average transaction amount for fraud vs non-fraud?
-- Goal: Compare spending behavior between fraudulent and legitimate transactions.

SELECT
    is_fraud,
    AVG(amount) AS avg_transaction_amount
FROM creditcard_fraud_synthetic
GROUP BY
    is_fraud;

-- Q5: Which customers have the most transactions?
-- Goal: Identify high-activity accounts for behavioral risk analysis.

SELECT
    customer_id,
    COUNT(*) AS total_transactions
FROM creditcard_fraud_synthetic
GROUP BY
    customer_id
ORDER BY
    total_transactions DESC
LIMIT 10;

-- Q6: How does time between transactions differ for fraud vs non-fraud?
-- Goal: Detect rapid-fire transaction behavior common in fraud patterns.

SELECT
    is_fraud,
    AVG(minutes_since_last_transaction) AS avg_minutes_between_txns
FROM creditcard_fraud_synthetic
GROUP BY
    is_fraud;

-- Q7: How often do fraud vs non-fraud transactions occur at night?
-- Goal: Identify whether fraud is more common during late hours.

SELECT
    is_fraud,
    COUNT(*) AS total_transactions,
    SUM(is_night) AS night_transactions,
    SUM(is_night) / COUNT(*) AS pct_night_transactions
FROM creditcard_fraud_synthetic
GROUP BY
    is_fraud;

-- Q8: Are foreign transactions more likely to be fraudulent?
-- Goal: Measure fraud prevalence in foreign vs domestic transactions.

SELECT
    is_foreign_transaction,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    SUM(is_fraud) / COUNT(*) AS pct_fraud
FROM creditcard_fraud_synthetic
GROUP BY
    is_foreign_transaction;

-- Q9: Which merchant categories have the highest fraud counts?
-- Goal: Identify fraud-prone merchant categories.

SELECT
    merchant_category,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    SUM(is_fraud) / COUNT(*) AS fraud_rate
FROM creditcard_fraud_synthetic
GROUP BY
    merchant_category
ORDER BY
    fraud_transactions DESC
LIMIT 10;

-- Q10: Which customers show the strongest behavioral red flags?
-- Goal: Identify accounts with unusual or suspicious activity patterns.

SELECT
    customer_id,
    AVG(num_transactions_last_1h) AS avg_txns_last_1h,
    AVG(minutes_since_last_transaction) AS avg_minutes_between_txns,
    AVG(distance_from_last_transaction_km) AS avg_distance_between_txns,
    AVG(ip_address_risk_score) AS avg_ip_risk_score
FROM creditcard_fraud_synthetic
GROUP BY
    customer_id
ORDER BY
    avg_txns_last_1h DESC,
    avg_ip_risk_score DESC
LIMIT 10;
