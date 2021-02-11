WITH PortfolioInvestmentCommitmentList
AS (
	SELECT DISTINCT portfolioinvestmentid
	FROM [dbo].[PortfolioInvestment_CommitmentHistory]
	)
SELECT po.ShortName
	,p.InvestmentName
FROM PortfolioInvestment p
LEFT JOIN PortfolioInvestmentCommitmentList b ON b.portfolioinvestmentid = p.portfolioinvestmentid
INNER JOIN Portfolio po on po.PortfolioID = p.PortfolioID
WHERE b.PortfolioInvestmentId IS NULL
