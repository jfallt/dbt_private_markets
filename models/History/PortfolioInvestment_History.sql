{{ config(materialized='table') }}
select p.PortfolioInvestmentID
	,ch.PortfolioId
	,ch.GPFundId
	,Portfolio
	,Investment
	,EffectiveDate
	,CommitmentAmountLocal
	,AdjustedCommitmentAmountLocal
from [dbo].[CommitmentHistoryProcessed] ch
left join [dbo].[PortfolioInvestment] p
	on p.PortfolioID = ch.PortfolioId
	and p.GPFundID = ch.GPFundId
where Portfolio <> Investment
and ch.PortfolioId is not null