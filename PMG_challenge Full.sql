-- CREATE database PMG;
-- USE PMG;

-- CREATE TABLE marketing_data(date date,
-- 					 geo varchar(8),
--                      impressions int,
--                      clicks int);

-- CREATE TABLE store_revenue(date date,
-- 					 brand_id int,
-- 				     store_location varchar(24),
--                   revenue int);

-- INSERT INTO marketing_data VALUES
-- ("2016-01-01","TX","2532","45"),
-- ("2016-01-01","CA","3425","63"),
-- ("2016-01-01","NY","3532","25"),
-- ("2016-01-01","MN","1342","784"),
-- ("2016-01-02","TX","3643","23"),
-- ("2016-01-02","CA","1354","53"),
-- ("2016-01-02","NY","4643","85"),
-- ("2016-01-02","MN","2366","85"),
-- ("2016-01-03","TX","2353","57"),
-- ("2016-01-03","CA","5258","36"),
-- ("2016-01-03","NY","4735","63"),
-- ("2016-01-03","MN","5783","87"),
-- ("2016-01-04","TX","5783","47"),
-- ("2016-01-04","CA","7854","85"),
-- ("2016-01-04","NY","4754","36"),
-- ("2016-01-04","MN","9345","24"),
-- ("2016-01-05","TX","2535","63"),
-- ("2016-01-05","CA","4678","73"),
-- ("2016-01-05","NY","2364","33"),
-- ("2016-01-05","MN","3452","25");

-- INSERT INTO store_revenue VALUES
-- ("2016-01-01","1","United States-CA","100"),
-- ("2016-01-01","1","United States-TX","420"),
-- ("2016-01-01","1","United States-NY","142"),
-- ("2016-01-02","1","United States-CA","231"),
-- ("2016-01-02","1","United States-TX","2342"),
-- ("2016-01-02","1","United States-NY","232"),
-- ("2016-01-03","1","United States-CA","100"),
-- ("2016-01-03","1","United States-TX","420"),
-- ("2016-01-03","1","United States-NY","3245"),
-- ("2016-01-04","1","United States-CA","34"),
-- ("2016-01-04","1","United States-TX","3"),
-- ("2016-01-04","1","United States-NY","54"),
-- ("2016-01-05","1","United States-CA","45"),
-- ("2016-01-05","1","United States-TX","423"),
-- ("2016-01-05","1","United States-NY","234"),
-- ("2016-01-01","2","United States-CA","234"),
-- ("2016-01-01","2","United States-TX","234"),
-- ("2016-01-01","2","United States-NY","142"),
-- ("2016-01-02","2","United States-CA","234"),
-- ("2016-01-02","2","United States-TX","3423"),
-- ("2016-01-02","2","United States-NY","2342"),
-- ("2016-01-03","2","United States-CA","234234"),
-- ("2016-01-06","3","United States-TX","3"),
-- ("2016-01-03","2","United States-TX","3"),
-- ("2016-01-03","2","United States-NY","234"),
-- ("2016-01-04","2","United States-CA","2"),
-- ("2016-01-04","2","United States-TX","2354"),
-- ("2016-01-04","2","United States-NY","45235"),
-- ("2016-01-05","2","United States-CA","23"),
-- ("2016-01-05","2","United States-TX","4"),
-- ("2016-01-05","2","United States-NY","124");

-- Question #0 Select the first 2 rows from the marketing data​
SELECT *
FROM marketing_data
LIMIT 2;

-- Question #1 Generate a query to get the sum of the clicks of the marketing data​
SELECT SUM(clicks) AS total_clicks
FROM marketing_data;

-- Question #2 Generate a query to gather the sum of revenue by geo from the store_revenue table​
SELECT RIGHT(store_location,2) AS geo, SUM(revenue) AS revenue 
FROM store_revenue 
GROUP BY RIGHT(store_location, 2);


-- Question #3 Merge these two datasets so we can see impressions, clicks and revenue together by date and geo.
-- Please ensure all records from each table are accounted for.​
SELECT m.*, a.revenue
FROM marketing_data m
LEFT JOIN (SELECT date, RIGHT(store_location, 2) AS geo, SUM(revenue) AS revenue 
            FROM store_revenue 
			GROUP BY date, store_location
            ) a
ON m.geo = a.geo AND m.date = a.date;


-- Question #4 In your opinion, what is the most efficient store and why?​ 
SELECT geo, SUM(impressions) AS total_impression, SUM(clicks) AS total_clicks, SUM(revenue) AS total_rev, SUM(clicks)/SUM(impressions) AS CTR, SUM(revenue)/SUM(impressions) AS RPI
FROM store_revenue
RIGHT JOIN marketing_data
ON RIGHT(store_revenue.store_location, 2) = marketing_data.geo AND store_revenue.date = marketing_data.date
GROUP BY geo
ORDER BY RPI desc, CTR desc;

SELECT b.geo, 
       SUM(b.impressions) AS total_impression, 
       SUM(b.clicks) AS total_clicks, 
       SUM(b.revenue) AS total_rev, 
       SUM(b.clicks)/SUM(b.impressions) AS CTR, 
       SUM(b.revenue)/SUM(b.impressions) AS RPI
FROM (SELECT DISTINCT m.*, a.revenue
      FROM marketing_data m
      LEFT JOIN (SELECT date, RIGHT(store_location, 2) AS geo, SUM( distinct revenue) AS revenue 
                 FROM store_revenue 
			     GROUP BY date, store_location
                 ) a
ON m.geo = a.geo AND m.date = a.date ) b
GROUP BY b.geo
ORDER BY RPI DESC;

-- Answer: I think it depends on which index we want to look into. In my opinion, revenue is always the priority.
-- RPI (revenue per impression) is a metric that shows the ratio between impressions and the amount of money we make.
-- In this way, CA store seems the most efficient one since we can make $10.4230 per impression. The second hightest is only $2.5885.
-- Click through rate also matters since it can show if our advertisement can attract customer to look into more details.
-- In this way, MN store seems the most efficient. However, we don't have revenue data to support. TX is the second highest one, but only 0.0002 higher than CA.
-- To summarize, CA store is the most efficient store according to both CTR and RPI.

-- Question #5 (Challenge) Generate a query to rank in order the top 10 revenue producing states​
-- I don't quiet understand the question. Should I find top 10 revenue state for each day? or just rank by total state revenue?
-- My answer below is for finding out the top 10 revenue state for each day
SELECT b.*,  DENSE_RANK() OVER(PARTITION BY b.date ORDER BY b.state_everyday_revenue DESC) AS 'Rank'
FROM (SELECT a.date, geo, SUM(a.revenue) OVER(PARTITION BY a.date, geo) AS state_everyday_revenue 
	  FROM (SELECT date, RIGHT(store_location,2) as geo, sum(revenue) as revenue 
            FROM store_revenue 
            GROUP BY date, store_location) a
      ORDER BY date, revenue desc) b ; 



