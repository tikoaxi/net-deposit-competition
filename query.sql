SELECT
  j.Country, y.IBName, z.AgentCode, z.TotalND, z.NTC_ND, z.ExistingND, z.Active_Clients, z.NTC
FROM (
  SELECT
    CASE WHEN w.Introducing_Broker_Ref IS NULL THEN TA.AgentCode ELSE w.Introducing_Broker_Ref END AS AgentCode,
    SUM(x.Deposits + x.Withdrawals) AS TotalND,
    SUM(CASE WHEN X.NTC_daily = 1 THEN x.Deposits + x.Withdrawals END) AS NTC_ND,
    SUM(CASE WHEN X.NTC_daily = 0 THEN x.Deposits + x.Withdrawals END) AS ExistingND,
    COUNT(DISTINCT CASE WHEN x.actives = 1 THEN x.ClientId END) AS Active_Clients,
    COUNT(DISTINCT CASE WHEN x.ntc_daily = 1 THEN x.ClientId END) AS NTC
  FROM fpa.daily_kpi.daily_kpi_bo x
  LEFT JOIN (
    SELECT DISTINCT CustomerId, AgentCode FROM (
      SELECT DISTINCT Customer_Id AS CustomerId, Agent_Code AS AgentCode,
        MAX(Last_updated) OVER(PARTITION BY Customer_id) AS max_last_updated, last_updated
      FROM prod_gold.dbt_customers.fct_trading_account
    ) WHERE last_updated = max_last_updated
  ) TA ON TA.CustomerId = x.ClientID
  LEFT JOIN prod_gold.dbt_customers.fct_customer w ON w.Customer_Id = x.ClientID
  WHERE date_format(x.date, 'yyyy-MM-dd') >= '2026-05-15'
  GROUP BY 1
) z
LEFT JOIN fpa.client_stats.ibname y ON z.AgentCode = y.IBName
LEFT JOIN prod_gold.dbt_customers.fct_trading_account u ON u.platform_login = z.AgentCode
LEFT JOIN prod_gold.dbt_customers.fct_customer j ON u.customer_id = j.customer_id
WHERE z.AgentCode IN (
  '4739440','4727027','402612','4740341','4727571','829726','4227663','4423270',
  '872412','4734001','4727252','4729317','4727422','4727245','4733537','4735645',
  '4727039','4709067','4727029','4734464','4741551','4406000'
)
