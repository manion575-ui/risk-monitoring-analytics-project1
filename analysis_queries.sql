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

