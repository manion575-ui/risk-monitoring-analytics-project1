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

-- Q11: Identify transactions with multiple simultaneous risk indicators.
-- Goal: Spot transactions that combine several suspicious behaviors.

SELECT
    transaction_id,
    customer_id,
    amount,
    is_night,
    is_foreign_transaction,
    ip_address_risk_score,
    failed_pin_attempts_24h
FROM creditcard_fraud_synthetic
WHERE
    is_night = 1
    AND is_foreign_transaction = 1
    AND ip_address_risk_score > 70
    AND failed_pin_attempts_24h > 0
ORDER BY
    ip_address_risk_score DESC;

-- Q12: Create a simple rule-based risk score using CASE WHEN logic.
-- Goal: Assign points for suspicious behaviors.

SELECT
    transaction_id,
    customer_id,
    amount,
    CASE
        WHEN amount > 500 THEN 2
        ELSE 0
    END +
    CASE
        WHEN is_night = 1 THEN 1
        ELSE 0
    END +
    CASE
        WHEN is_foreign_transaction = 1 THEN 2
        ELSE 0
    END +
    CASE
        WHEN ip_address_risk_score > 80 THEN 3
        ELSE 0
    END AS risk_score
FROM creditcard_fraud_synthetic
ORDER BY
    risk_score DESC
LIMIT 20;

-- Q13: Find high-risk transactions that were not labeled as fraud.
-- Goal: Identify potential false negatives.

SELECT
    transaction_id,
    customer_id,
    amount,
    is_fraud,
    ip_address_risk_score,
    minutes_since_last_transaction
FROM creditcard_fraud_synthetic
WHERE
    is_fraud = 0
    AND ip_address_risk_score > 85
    AND minutes_since_last_transaction < 2
ORDER BY
    ip_address_risk_score DESC;

-- Q14: Which customers have the highest fraud rates?
-- Goal: Identify accounts repeatedly involved in fraud.

SELECT
    customer_id,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    SUM(is_fraud) / COUNT(*) AS fraud_rate
FROM creditcard_fraud_synthetic
GROUP BY
    customer_id
HAVING
    COUNT(*) > 10
ORDER BY
    fraud_rate DESC
LIMIT 20;

-- Q15: Identify merchants with unusually high fraud rates.
-- Goal: Detect merchant-level fraud patterns.

SELECT
    merchant_id,
    merchant_category,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    SUM(is_fraud) / COUNT(*) AS fraud_rate
FROM creditcard_fraud_synthetic
GROUP BY
    merchant_id, merchant_category
HAVING
    COUNT(*) > 20
ORDER BY
    fraud_rate DESC
LIMIT 20;

-- Q16: Rank transactions by risk using window functions.
-- Goal: Produce a prioritized list of suspicious transactions.

SELECT
    transaction_id,
    customer_id,
    amount,
    ip_address_risk_score,
    ROW_NUMBER() OVER (
        ORDER BY ip_address_risk_score DESC, amount DESC
    ) AS risk_rank
FROM creditcard_fraud_synthetic
LIMIT 20;

-- Q17: Identify rapid-fire transaction bursts.
-- Goal: Detect suspicious high-frequency activity.

SELECT
    transaction_id,
    customer_id,
    num_transactions_last_1h,
    minutes_since_last_transaction,
    amount
FROM creditcard_fraud_synthetic
WHERE
    num_transactions_last_1h > 5
    AND minutes_since_last_transaction < 3
ORDER BY
    num_transactions_last_1h DESC;

-- Q18: Identify transactions with large geographic jumps.
-- Goal: Detect location-based anomalies.

SELECT
    transaction_id,
    customer_id,
    distance_from_home_km,
    distance_from_last_transaction_km,
    is_fraud
FROM creditcard_fraud_synthetic
WHERE
    distance_from_home_km > 50
    AND distance_from_last_transaction_km > 20
ORDER BY
    distance_from_last_transaction_km DESC;

-- Q19: Build a combined behavioral + monetary risk score.
-- Goal: Create a more complete risk scoring model.

SELECT
    transaction_id,
    customer_id,
    amount,
    num_transactions_last_1h,
    ip_address_risk_score,
    (
        CASE WHEN amount > 500 THEN 2 ELSE 0 END +
        CASE WHEN num_transactions_last_1h > 3 THEN 2 ELSE 0 END +
        CASE WHEN ip_address_risk_score > 80 THEN 3 ELSE 0 END +
        CASE WHEN is_foreign_transaction = 1 THEN 2 ELSE 0 END
    ) AS combined_risk_score
FROM creditcard_fraud_synthetic
ORDER BY
    combined_risk_score DESC
LIMIT 20;

-- Q20: Identify the top 20 riskiest customers.
-- Goal: Produce a final prioritized customer risk list.

SELECT
    customer_id,
    AVG(amount) AS avg_amount,
    AVG(ip_address_risk_score) AS avg_ip_risk,
    AVG(num_transactions_last_1h) AS avg_txn_bursts,
    SUM(is_fraud) AS total_fraud_events,
    (
        AVG(ip_address_risk_score) * 0.4 +
        AVG(num_transactions_last_1h) * 0.3 +
        SUM(is_fraud) * 0.3
    ) AS customer_risk_score
FROM creditcard_fraud_synthetic
GROUP BY
    customer_id
ORDER BY
    customer_risk_score DESC
LIMIT 20;
