{{ config(materialized='table') }}
select PortfolioId
	,[EffectiveDate]
	,[CommitmentAmountLocal]
	,[AdjustedCommitmentAmountLocal]
from [dbo].[CommitmentHistoryProcessed]
where Portfolio = Investment
and PortfolioId is not null