{{ config(materialized='table') }}
select PortfolioId
	,[EffectiveDate]
	,[CommitmentAmountLocal]
	,[AdjustedCommitmentAmountLocal]
from {{ref('CommitmentHistoryProcessed')}}
where Portfolio = Investment
and PortfolioId is not null