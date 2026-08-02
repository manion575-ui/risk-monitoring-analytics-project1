-- Analysis queries for Risk Monitoring Analytics Project
-- All queries are tied to specific risk questions.
-- continuing to use Copilot for this. Will save prompy/reponse in OneNote. instead of being handed the queries I asked it to gradually feed it to me.

-- Q1: What does a sample of transactions look like?
-- Goal: Get familiar with the columns and values.

SELECT
transaction_id,
customer_id,
amount,
is_fraud
FROM creditcard_fraud_synthetic_small
LIMIT 10;
