{{ config(materialized='table') }}
select p.PortfolioInvestmentID
	,ch.PortfolioId
	,ch.GPFundId
	,Portfolio
	,Investment
	,EffectiveDate
	,CommitmentAmountLocal
	,AdjustedCommitmentAmountLocal
from {{ref('CommitmentHistoryProcessed')}} ch
left join {{ref('PortfolioInvestment')}} p
	on p.PortfolioID = ch.PortfolioId
	and p.GPFundID = ch.GPFundId
where Portfolio <> Investment
and ch.PortfolioId is not null