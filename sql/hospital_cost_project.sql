-- Create databased
CREATE TABLE age_group
(
group_name VARCHAR (100) PRIMARY KEY,
age_min INT,
age_max INT);
INSERT INTO age_group (group_name, age_min, age_max)
VALUES  ('Under 25', 0, 24),
		('25 - 34', 25, 34),
        ('35 - 44', 35, 44),
        ('45 - 54', 45, 54),
        ('55+', 55, 99);

CREATE TABLE bmi_group
(
group_name VARCHAR (100) PRIMARY KEY,
bmi_min DECIMAL(5,2),
bmi_max DECIMAL(5,2));
INSERT INTO bmi_group (group_name, bmi_min, bmi_max)
VALUES ('Underweight', 0, 18.49),
	   ('Normal', 18.5, 22.99),
       ('Overweight', 23, 24.99),
       ('Obese I', 25, 29.99),
       ('Obese II', 30, 99);
       
CREATE TABLE cost_group
(
group_name VARCHAR (100) PRIMARY KEY,
cost_min INT,
cost_max INT);
INSERT INTO cost_group (group_name, cost_min, cost_max)
VALUES ('Low', 0, 9999),
	   ('Medium', 10000, 19999),
       ('High', 20000, 39999),
       ('Very High', 40000, 70000);

-- Test percentile of 3 groups
SELECT
	group_name,
    COUNT(*) AS pp_num,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,0) AS perc_pp,
    ROUND(SUM(based.charges),4) AS total_cost,
    ROUND(SUM(based.charges)/(SELECT SUM(charges) FROM hospitalcost)*100,0) AS perc_cost,
    ROUND(AVG(based.charges),4) AS avg_cost
FROM hospitalcost based
JOIN age_group age ON based.age BETWEEN age.age_min AND age.age_max
GROUP BY group_name;
	-- Comment: The distribution rate of age group is uniform, but the distribution cost increases progressively with age

SELECT
	group_name,
    COUNT(*) AS pp_num,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,0) AS perc_pp,
    ROUND(SUM(based.charges),4) AS total_cost,
    ROUND(SUM(based.charges)/(SELECT SUM(charges) FROM hospitalcost)*100,0) AS perc_cost,
    ROUND(AVG(based.charges),4) AS avg_cost
FROM hospitalcost based
JOIN bmi_group bmi ON based.bmi BETWEEN bmi.bmi_min AND bmi.bmi_max
GROUP BY group_name;
	-- Comment: Same with age
    
SELECT 
	group_name,
    COUNT(*) AS pp_num,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,0) AS perc_pp,
    ROUND(SUM(based.charges),4) AS total_cost,
    ROUND(SUM(based.charges)/(SELECT SUM(charges) FROM hospitalcost)*100,0) AS perc_cost,
    ROUND(AVG(based.charges),4) AS avg_cost
FROM hospitalcost based
JOIN cost_group cost ON based.charges BETWEEN cost.cost_min AND cost.cost_max
GROUP BY group_name;
	-- Comment: Low and Medium take up to 79% of people, 48% cost; High and Very High 21% of pp, 52% of cost
    
-- Analysis
SELECT * FROM hospitalcost;

SELECT
	ROUND(AVG(age),0) AS avg_age,
	COUNT(CASE WHEN sex = 'male' THEN 1 END) AS amt_male,
    COUNT(CASE WHEN sex = 'female' THEN 1 END) AS amt_female,
    COUNT(CASE WHEN children > 0 THEN 1 END) AS having_chil,
	ROUND(AVG(bmi),0) AS avg_bmi,
    COUNT(CASE WHEN smoker = 'yes' THEN 1 END) AS amt_smoker,
    COUNT(CASE WHEN region = 'southwest' THEN 1 END) AS southwest,
    COUNT(CASE WHEN region = 'southeast' THEN 1 END) AS southeast,
    COUNT(CASE WHEN region = 'northwest' THEN 1 END) AS northwest,
    COUNT(CASE WHEN region = 'northeast' THEN 1 END) AS northeast,
    MIN(charges) AS min_charges,
    MAX(charges) AS max_charges,
    AVG(charges) AS avg_charges
FROM hospitalcost;

-- Descriptive analysis
	-- Cost by smoker
WITH ranked AS (
	SELECT
		smoker,
        charges,
        ROW_NUMBER () OVER(
			PARTITION BY smoker ORDER BY charges
		) AS rn,
        COUNT(*) OVER(
			PARTITION BY smoker
		) AS cnt
	FROM hospitalcost
),
	 median_smoker AS (
	SELECT
		smoker,
		AVG(charges) AS median_cost
	FROM ranked
	WHERE rn IN ( FLOOR((cnt + 1)/2), FLOOR((cnt + 2) /2))
    GROUP BY smoker
)
SELECT
	based.smoker,
	COUNT(*) AS num_pp,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,2) AS perc_pp,
    ROUND(AVG(charges),2) AS avg_cost,
    med.median_cost,
    SUM(charges) AS total_cost,
    ROUND((SUM(charges)/(SELECT SUM(charges) FROM hospitalcost))*100,1) AS perc_cost
FROM hospitalcost based
JOIN median_smoker med ON based.smoker = med.smoker
GROUP BY based.smoker;

	-- Cost by age_group
SELECT
	group_name,
    COUNT(*) AS num_pp,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,2) AS perc_pp,
    ROUND(AVG(charges),2) AS avg_cost,
    SUM(charges) AS total_cost,
    ROUND((SUM(charges)/(SELECT SUM(charges) FROM hospitalcost))*100,1) AS perc_cost
FROM hospitalcost based
JOIN age_group age ON based.age BETWEEN age.age_min AND age.age_max
GROUP BY group_name;

	-- Cost by bmi_group
WITH ranked AS (
	SELECT
		group_name,
        charges,
        ROW_NUMBER () OVER(
			PARTITION BY group_name ORDER BY charges
		) AS rn,
        COUNT(*) OVER(
			PARTITION BY group_name
		) AS cnt
	FROM hospitalcost based
	JOIN bmi_group bmi ON based.bmi BETWEEN bmi.bmi_min AND bmi.bmi_max
),
	 median_bmi AS (
	SELECT
		group_name,
		AVG(charges) AS median_cost
	FROM ranked
	WHERE rn IN ( FLOOR((cnt + 1)/2), FLOOR((cnt + 2) /2))
    GROUP BY group_name
),
	summary_bmi AS (
    SELECT
		bmi.group_name,
		COUNT(*) AS num_pp,
		ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,2) AS perc_pp,
		ROUND(AVG(charges),2) AS avg_cost,
		SUM(charges) AS total_cost,
		ROUND((SUM(charges)/(SELECT SUM(charges) FROM hospitalcost))*100,1) AS perc_cost
	FROM hospitalcost based
	JOIN bmi_group bmi ON based.bmi BETWEEN bmi.bmi_min AND bmi.bmi_max
	GROUP BY bmi.group_name
)
SELECT
	s.group_name,
    s.num_pp,
    s.perc_pp,
    s.avg_cost,
    m.median_cost,
    s.total_cost,
    s.perc_cost
FROM summary_bmi s
JOIN median_bmi m ON s.group_name = m.group_name;

	-- Cost by region
SELECT
	region,
    COUNT(*) AS num_pp,
	ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,2) AS perc_pp,
	ROUND(AVG(charges),2) AS avg_cost,
    SUM(charges) AS total_cost,
    ROUND((SUM(charges)/(SELECT SUM(charges) FROM hospitalcost))*100,1) AS perc_cost
FROM hospitalcost
GROUP BY region;
			-- The difference isn't too significant

	-- Cost by children
SELECT
	children,
	COUNT(*) AS num_pp,
	ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,2) AS perc_pp,
	ROUND(AVG(charges),2) AS avg_cost,
    SUM(charges) AS total_cost,
    ROUND((SUM(charges)/(SELECT SUM(charges) FROM hospitalcost))*100,1) AS perc_cost
FROM hospitalcost
GROUP BY children;
		-- The data is still confusing, need to dive further

	-- Cost by sex
SELECT
	sex,
	COUNT(*) AS num_pp,
	ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,2) AS perc_pp,
	ROUND(AVG(charges),2) AS avg_cost,
    SUM(charges) AS total_cost,
    ROUND((SUM(charges)/(SELECT SUM(charges) FROM hospitalcost))*100,1) AS perc_cost
FROM hospitalcost
GROUP BY sex;

-- Condition analysis
	-- age_goup x smoker
SELECT
    age.group_name AS group_age,
    smoker,
    COUNT(*) AS num_pp,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,2) AS perc_pp,
    ROUND(AVG(charges),2) AS avg_cost,
    SUM(charges) AS total_cost,
    ROUND((SUM(charges)/(SELECT SUM(charges) FROM hospitalcost))*100,1) AS perc_cost
FROM hospitalcost based
JOIN age_group age ON based.age BETWEEN age.age_min AND age.age_max
GROUP BY age.group_name, smoker;

	-- age_group x bmi_group
SELECT
	age.group_name AS group_age,
    bmi.group_name AS group_bmi,
	COUNT(*) AS num_pp,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,2) AS perc_pp,
    ROUND(AVG(charges),2) AS avg_cost,
    SUM(charges) AS total_cost,
    ROUND((SUM(charges)/(SELECT SUM(charges) FROM hospitalcost))*100,1) AS perc_cost
FROM hospitalcost based
JOIN age_group age ON based.age BETWEEN age.age_min AND age.age_max
JOIN bmi_group bmi ON based.bmi BETWEEN bmi.bmi_min AND bmi.bmi_max
GROUP BY age.group_name, bmi.group_name;

	-- bmi_group x smoker
SELECT
	bmi.group_name AS group_bmi,
    smoker,
    COUNT(*) AS num_pp,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100,2) AS perc_pp,
    ROUND(AVG(charges),2) AS avg_cost,
    SUM(charges) AS total_cost,
    ROUND((SUM(charges)/(SELECT SUM(charges) FROM hospitalcost))*100,1) AS perc_cost
FROM hospitalcost based
JOIN bmi_group bmi ON based.bmi BETWEEN bmi.bmi_min AND bmi.bmi_max
GROUP BY smoker, group_name;

-- Risk segmentation
WITH risk_data AS(
	SELECT
		group_name,
        smoker,
        CASE
		  WHEN smoker = 'yes' AND LEFT(group_name, 5) = 'Obese' THEN 'Very high risk'
          WHEN smoker = 'yes' THEN 'High risk'
          WHEN LEFT(group_name, 5) = 'Obese' THEN 'Medium risk'
          ELSE 'Low risk'
		END AS risk_group,
        charges
	FROM hospitalcost based
    JOIN bmi_group bmi ON based.bmi BETWEEN bmi.bmi_min AND bmi.bmi_max
)
SELECT
	risk_group,
    ROUND(AVG(charges),0) AS avg_cost,
    ROUND(SUM(charges),0) AS total_cost,
    ROUND((SUM(charges)/(SELECT SUM(charges) FROM risk_data))*100,0) AS perc_cost, 
    COUNT(*) AS num_pp,
    ROUND((COUNT(*)/(SELECT COUNT(*) FROM risk_data))*100,0) AS perc_pp
FROM risk_data
GROUP BY risk_group;

-- High cost analysis
WITH ranked_cost AS(
SELECT 
	sex,
    age,
    bmi,
    smoker,
    charges,
    NTILE(10) OVER (ORDER BY charges) AS top_10
FROM hospitalcost
)
SELECT
	COUNT(*) AS num_pp,
    ROUND((COUNT(*)/(SELECT COUNT(*) FROM hospitalcost)*100),0) AS perc_pp, 
    (COUNT(CASE WHEN smoker = 'yes' THEN 1 END)/count(*))*100 AS perc_smoker,
    ROUND(AVG(bmi),3) AS avg_bmi,
    ROUND(AVG(age),0) AS avg_age,
    COUNT(CASE WHEN sex = 'male' THEN 1 END) AS num_m,
    COUNT(CASE WHEN sex = 'female' THEN 1 END) AS num_f
FROM ranked_cost
WHERE top_10 = 10;