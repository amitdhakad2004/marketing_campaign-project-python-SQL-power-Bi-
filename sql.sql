select * from marketing_campaign

--  Total number of campaigns run by each company
SELECT  company , COUNT(*) AS total_campaigns FROM marketing_campaign
GROUP BY company

--  Average conversion rate by campaign type
SELECT Campaign_Type, AVG(Conversion_Rate) AS avg_conversion_rate
FROM marketing_campaign
GROUP BY Campaign_Type;


--  Total clicks and impressions per channel
with cte as (
select Channel_Used, 
sum(Clicks) total_clicks, 
sum(Impressions) total_impressions    
from marketing_campaign
group by Channel_Used
)
select * ,
(cte.total_clicks) * 100.0 / (cte.total_impressions) AS Click_Through_Rate
from cte


-- Campaigns with high CTR and engagement (CTR = Click_Through_Rate , click / impression * 100.0%)
SELECT Campaign_ID, Clicks, Impressions, Engagement_Score 
FROM marketing_campaign
WHERE (Clicks * 100.0 / Impressions)> 70 AND Engagement_Score >= 7



-- Campaigns with cost per click (CPC)
SELECT Campaign_ID, Company, ROUND(Acquisition_Cost / Clicks, 2) AS CPC
FROM marketing_campaign


--  Average ROI per Campaign_Type (ROI = return on investment , ROI => 6.29 * 100 = 629%)
SELECT Campaign_Type, ROUND(AVG(ROI), 2) AS avg_roi
FROM marketing_campaign
GROUP BY Campaign_Type


--  Top  campaigns with highest ROI
SELECT Campaign_ID, Company, ROI
FROM marketing_campaign
WHERE ROI = (SELECT MAX(ROI) FROM marketing_campaign )


--  Top 5% ROI campaigns
SELECT *
FROM marketing_campaign
WHERE ROI >= (
  SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY ROI)
  FROM marketing_campaign
);


--  Audience-wise average ROI
SELECT Target_Audience, AVG(ROI) AS avg_roi
FROM marketing_campaign
GROUP BY Target_Audience;


--   customer segments by average ROI
SELECT Customer_Segment, ROUND(AVG(ROI), 2) AS avg_roi
FROM marketing_campaign
GROUP BY Customer_Segment
ORDER BY avg_roi DESC


--  Total  customer segments by distinct customer segments
SELECT Customer_Segment, COUNT(*) AS count
FROM marketing_campaign
GROUP BY Customer_Segment
ORDER BY count DESC


--  Monthly number of campaigns
SELECT TO_CHAR(Date , 'MM-YYYY') AS Month, COUNT(*) AS campaigns
FROM marketing_campaign
GROUP BY Month
ORDER BY Month;


--  Daily campaign count trend
SELECT Date, COUNT(*) AS total_campaigns
FROM marketing_campaign
GROUP BY Date
ORDER BY Date;


--  Campaigns with above-average engagement score
SELECT *
FROM marketing_campaign
WHERE Engagement_Score > (SELECT AVG(Engagement_Score) FROM marketing_campaign)


--  Average acquisition cost by campaign type
SELECT Campaign_Type, ROUND(AVG(Acquisition_Cost), 2) AS avg_cost
FROM marketing_campaign
GROUP BY Campaign_Type



--  Campaigns targeting Men 18-24 with ROI > 5
SELECT *
FROM marketing_campaign
WHERE Target_Audience = 'Men 18-24' AND ROI > 5;



-- Engagement score  per segment
SELECT Customer_Segment , ROUND(avg(Engagement_Score), 2)
FROM marketing_campaign
GROUP BY Customer_Segment


--  Channel with the most impressions in 2021
SELECT Channel_Used, SUM(Impressions) AS total_impressions
FROM marketing_campaign
GROUP BY Channel_Used
ORDER BY total_impressions DESC
LIMIT 1;


 -- Conversion rates grouped by segment and gender
SELECT Customer_Segment, Target_Audience, AVG(Conversion_Rate) AS avg_conversion
FROM marketing_campaign
GROUP BY Customer_Segment, Target_Audience;


 -- Duration-wise engagement average
SELECT Duration, AVG(Engagement_Score) AS avg_engagement
FROM marketing_campaign
GROUP BY Duration;


 -- Best performing audience per campaign type
SELECT Campaign_Type, Target_Audience, AVG(ROI) AS avg_roi 
FROM marketing_campaign
GROUP BY Campaign_Type, Target_Audience
ORDER BY Campaign_Type, avg_roi DESC


-- avg_Acquisition_Cost , avg_ROI by Target_Audience
SELECT Company, Campaign_Type , Target_Audience,
ROUND(AVG(Acquisition_Cost), 2 ) AS avg_Acquisition_Cost ,
ROUND(AVG(ROI), 2 ) AS avg_ROI
FROM marketing_campaign
group by Company, Campaign_Type , Target_Audience



-- Channel performance vs average ROI
SELECT Channel_Used, AVG(ROI) AS avg_channel_roi,
       (SELECT AVG(ROI) FROM marketing_campaign) AS overall_avg_roi
FROM marketing_campaign
GROUP BY Channel_Used;


--  Audience segments with ROI above channel average
WITH ChannelROI AS (
  SELECT Channel_Used, AVG(ROI) AS channel_avg_roi
  FROM marketing_campaign
  GROUP BY Channel_Used
)
SELECT mc.Campaign_ID, c.Channel_Used, mc.Target_Audience, mc.ROI, c.channel_avg_roi
FROM marketing_campaign mc
JOIN ChannelROI c ON mc.Channel_Used = c.Channel_Used
WHERE mc.ROI > c.channel_avg_roi;


--  Best performing customer segment per location
WITH cte AS (
SELECT Location, Customer_Segment, AVG(ROI) AS avg_roi ,
RANK() OVER (PARTITION BY  Location  ORDER BY  AVG(ROI) DESC ) AS rank
FROM marketing_campaign
GROUP BY Location, Customer_Segment
)
select * from cte
where rank = 1


--  Top campaign each month by clicks
WITH ranked AS  (
  SELECT  TO_CHAR(Date, 'mm-yyyy'), Campaign_Type , SUM(clicks) , 
   RANK() OVER (PARTITION BY TO_CHAR(Date, 'mm-yyyy') ORDER BY SUM(Clicks) DESC) AS rnk
  FROM marketing_campaign  
  GROUP BY  Campaign_Type , TO_CHAR(Date, 'mm-yyyy') 
)
SELECT *
FROM ranked
WHERE rnk = 1;


-- Most effective channel per segment (highest ROI)
WITH ranked AS (
SELECT Customer_Segment, Channel_Used, AVG(ROI) AS AVG_roi ,
RANK() OVER (PARTITION BY Customer_Segment ORDER BY AVG(ROI) DESC) AS rnk 
FROM marketing_campaign
GROUP BY Customer_Segment, Channel_Used
)
SELECT * FROM ranked
WHERE rnk = 1;


--  Most profitable campaign each segment
 WITH ranked AS 
 (
  SELECT  Customer_Segment, Campaign_Type , AVG(ROI), 
  RANK() OVER (PARTITION BY Customer_Segment ORDER BY AVG(ROI) DESC) AS rnk
  FROM marketing_campaign
  GROUP BY Campaign_Type , Customer_Segment
)
SELECT *
FROM ranked
WHERE rnk = 1;


--  Identify duplicate campaigns (same Company, Date, Channel)
SELECT Company, Date, Channel_Used, COUNT(*) AS duplicate_count
FROM marketing_campaign
GROUP BY Company, Date, Channel_Used
HAVING COUNT(*) > 1
ORDER BY Company , Date , duplicate_count DESC ;


--  Highest cost campaign each company
WITH ranked AS (
  SELECT Company, Campaign_Type , SUM(Acquisition_Cost),
  RANK() OVER (PARTITION BY Company ORDER BY SUM(Acquisition_Cost) DESC) AS cost_rank
  FROM marketing_campaign
  group by Company, Campaign_Type
) 
SELECT *
FROM ranked
WHERE cost_rank = 1;


--  ROI vs Acquisition Cost by campaign (ROI = return on investment , ROI => 6.0 * 100 = 600%)
SELECT  Campaign_Type , ROUND(AVG(Acquisition_Cost),2) AS avg_Acquisition_Cost, ROUND(AVG(ROI), 5) * 100  AS avg_roi
FROM marketing_campaign
GROUP BY Campaign_Type
ORDER BY AVG(Acquisition_Cost) DESC, AVG(ROI) DESC;




