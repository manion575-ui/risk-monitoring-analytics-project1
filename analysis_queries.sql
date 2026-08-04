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

