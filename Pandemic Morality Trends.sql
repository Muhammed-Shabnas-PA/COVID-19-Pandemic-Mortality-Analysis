create database Pandemic_Mortality_Trends;

use Pandemic_Mortality_Trends;

select * from COVID_19_Death_Data;

-- next steps are to check the data validation-- data inconsistency, datatypes, anamolies in the data.

-- first step will change the datatype of the respecive fields

select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS;

--- data_as_of, data_period_start, data_period_end --->> Date

alter table COVID_19_Death_Data
alter column data_as_of date;

alter table COVID_19_Death_Data
alter column data_period_start date;

alter table COVID_19_Death_Data
alter column data_period_end date;

--- COVID_deaths --->> Int

alter table COVID_19_Death_Data
alter column COVID_deaths int;

--- COVID_pct_of_total, pct_change_wk, pct_diff_wk, crude_COVID_rate, aa_COVID_rate  --->>float (Decimal)
--- COVID_pct_of_total
alter table COVID_19_Death_Data
alter column COVID_pct_of_total decimal(15,2);  ---Error converting data type varchar to numeric.

update COVID_19_Death_Data
set COVID_pct_of_total = NULL
where COVID_pct_of_total='';    --- Replace empty columns with NULL

alter table COVID_19_Death_Data
alter column COVID_pct_of_total decimal(15,2);  --Converted Suuccessfully

--- pct_change_wk
alter table COVID_19_Death_Data
alter column pct_change_wk decimal(15,2);  ---Error converting data type varchar to numeric.

update COVID_19_Death_Data
set pct_change_wk = NULL
where pct_change_wk='';    --- Replace empty columns with NULL

alter table COVID_19_Death_Data
alter column pct_change_wk decimal(15,2);  --Converted Suuccessfully

--- pct_diff_wk
alter table COVID_19_Death_Data
alter column pct_diff_wk decimal(15,2);  ---Error converting data type varchar to numeric.

update COVID_19_Death_Data
set pct_diff_wk = NULL
where pct_diff_wk='';    --- Replace empty columns with NULL

alter table COVID_19_Death_Data
alter column pct_diff_wk decimal(15,2);  --Converted Suuccessfully

--- crude_COVID_rate
alter table COVID_19_Death_Data
alter column crude_COVID_rate decimal(15,2);  ---Error converting data type varchar to numeric.

update COVID_19_Death_Data
set crude_COVID_rate = NULL
where crude_COVID_rate='';    --- Replace empty columns with NULL

alter table COVID_19_Death_Data
alter column crude_COVID_rate decimal(15,2);  --Converted Suuccessfully

--- aa_COVID_rate
alter table COVID_19_Death_Data
alter column aa_COVID_rate decimal(15,2);  ---Error converting data type varchar to numeric.

update COVID_19_Death_Data
set aa_COVID_rate = NULL
where aa_COVID_rate='';    --- Replace empty columns with NULL

alter table COVID_19_Death_Data
alter column aa_COVID_rate decimal(15,2);  --Converted Suuccessfully

select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS;

--- 1. Retrieve the jurisdiction residence with the highest number of COVID deaths for the latest data period end date.

WITH LatestPeriod AS (
    SELECT 
        Jurisdiction_Residence, 
        COVID_deaths, 
        data_period_end,
        RANK() OVER (ORDER BY data_period_end DESC) AS date_rank
    FROM COVID_19_Death_Data
)
SELECT TOP 1 Jurisdiction_Residence, SUM(COVID_deaths) AS Total_COVID_deaths
FROM LatestPeriod
WHERE date_rank = 1
GROUP BY Jurisdiction_Residence
ORDER BY Total_COVID_deaths DESC; 

/*The jurisdiction with the highest number of COVID-19 deaths for the latest recorded period is the United States, 
with total 11,46,094 deaths */

--- 2. Retrieve the top 5 jurisdictions with the highest percentage difference in aa_COVID_rate  compared to the 
---    overall crude COVID rate for the latest data period end date.

WITH LatestPeriod AS (
    SELECT 
        Jurisdiction_Residence, 
        aa_COVID_rate, 
        crude_COVID_rate, 
        data_period_end,
        RANK() OVER (ORDER BY data_period_end DESC) AS date_rank
    FROM COVID_19_Death_Data
)
SELECT TOP 5 
    Jurisdiction_Residence, 
    SUM(aa_COVID_rate) AS Total_aa_COVID_rate, 
    SUM(crude_COVID_rate) AS Total_crude_COVID_rate,
    ((SUM(aa_COVID_rate) - SUM(crude_COVID_rate)) / NULLIF(SUM(crude_COVID_rate), 0)) * 100 AS Total_pct_difference
FROM LatestPeriod
WHERE date_rank = 1
GROUP BY Jurisdiction_Residence
ORDER BY Total_pct_difference DESC;

/* The top five jurisdictions with the highest percentage difference in aa_COVID_rate compared to the overall crude COVID rate 
for the latest recorded period are Utah, Alaska, District of Columbia, and Region 6. */

--- 3. Calculate the average COVID deaths per week for each jurisdiction residence and group, for  the latest 4 data period end dates.

WITH LatestPeriods AS (
    SELECT 
        Jurisdiction_Residence, 
        [Group], 
        data_period_start, 
        data_period_end, 
        COVID_deaths,
        RANK() OVER (ORDER BY data_period_end DESC) AS date_rank
    FROM COVID_19_Death_Data
)
SELECT 
    Jurisdiction_Residence, 
    [Group], 
    CAST(SUM(COVID_deaths) / NULLIF(SUM(DATEDIFF(DAY, data_period_start, data_period_end)) / 7.0, 0) AS DECIMAL(10,2)) AS avg_weekly_COVID_deaths
FROM LatestPeriods
WHERE date_rank <= 4
GROUP BY Jurisdiction_Residence, [Group]
ORDER BY Jurisdiction_Residence, [Group];

--- 4. Retrieve the data for the latest data period end date, but exclude any jurisdictions that had  zero COVID deaths and have 
---    missing values in any other column.

WITH WithoutMissingValues AS (
	SELECT *
	FROM COVID_19_Death_Data
	WHERE data_as_of IS NOT NULL AND Jurisdiction_Residence IS NOT NULL AND [Group] IS NOT NULL AND data_period_start IS NOT NULL AND data_period_end IS NOT NULL AND 
		  COVID_deaths IS NOT NULL AND COVID_pct_of_total IS NOT NULL AND pct_change_wk IS NOT NULL AND pct_diff_wk IS NOT NULL AND crude_COVID_rate IS NOT NULL AND 
		  aa_COVID_rate IS NOT NULL
),
	LatestPeriod AS (
	SELECT *,
		   RANK () OVER (ORDER BY data_period_end DESC) AS Date_Rank
	FROM WithoutMissingValues
)

SELECT data_as_of,
	Jurisdiction_Residence,
	[Group],
	data_period_start,
	data_period_end,
	COVID_deaths,
	COVID_pct_of_total,
	pct_change_wk,
	pct_diff_wk,
	crude_COVID_rate,
	aa_COVID_rate,
	footnote
FROM LatestPeriod
WHERE COVID_deaths >0 AND Date_Rank = 1
ORDER BY COVID_deaths DESC;


select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS;

--- 5. Calculate the week-over-week percentage change in COVID_pct_of_total for all jurisdictions  and groups, but only for the data period 
--  start dates after March 1, 2020.

WITH WeeklyData AS (
    SELECT 
        Jurisdiction_Residence,
        [Group],
        data_period_start,
        data_period_end,
        COVID_pct_of_total,
        LAG(COVID_pct_of_total) OVER (
            PARTITION BY Jurisdiction_Residence, [Group] 
            ORDER BY data_period_start
        ) AS Prev_Week_COVID_pct
    FROM COVID_19_Death_Data
    WHERE data_period_start > '2020-03-01'
)

SELECT 
    Jurisdiction_Residence,
    [Group],
    data_period_start,
    data_period_end,
    COVID_pct_of_total,
    Prev_Week_COVID_pct,
    CASE 
        WHEN Prev_Week_COVID_pct IS NULL THEN NULL
        ELSE ((COVID_pct_of_total - Prev_Week_COVID_pct) / NULLIF(Prev_Week_COVID_pct,0)) * 100
    END AS WoW_Percent_Change
FROM WeeklyData
ORDER BY Jurisdiction_Residence, [Group], data_period_start;

--- 6. Group the data by jurisdiction residence and calculate the cumulative COVID deaths for each  jurisdiction, but only up to the 
---  latest data period end date.

WITH CumulativeDeaths AS (
    SELECT 
        Jurisdiction_Residence,
        data_period_end,
        SUM(COVID_deaths) OVER (
            PARTITION BY Jurisdiction_Residence 
            ORDER BY data_period_end 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS Cumulative_COVID_Deaths
    FROM COVID_19_Death_Data
)

SELECT 
    Jurisdiction_Residence,
    data_period_end,
    Cumulative_COVID_Deaths
FROM CumulativeDeaths
WHERE data_period_end = (SELECT MAX(data_period_end) FROM COVID_19_Death_Data)
ORDER BY Cumulative_COVID_Deaths DESC;

/*--- 7. Implementation of Function & Procedure-"Create a stored procedure that takes in a date  range and calculates the average weekly 
percentage change in COVID deaths for each  jurisdiction. The procedure should return the average weekly percentage change along with  
the jurisdiction and date range as output. Additionally, create a user-defined function that  takes in a jurisdiction as input and returns 
the average crude COVID rate for that jurisdiction  over the entire dataset. Use both the stored procedure and the user-defined function to 
compare the average weekly percentage change in COVID deaths for each jurisdiction to the  average crude COVID rate for that jurisdiction.*/


--- User-Defined Function
CREATE FUNCTION dbo.fn_AvgCrudeCOVIDRate (@Jurisdiction NVARCHAR(255))
RETURNS FLOAT
AS
BEGIN
    DECLARE @AvgCrudeRate FLOAT;

    SELECT @AvgCrudeRate = AVG(crude_COVID_rate)
    FROM COVID_19_Death_Data
    WHERE Jurisdiction_Residence = @Jurisdiction;

    RETURN @AvgCrudeRate;
END;


--- Stored Procedure
CREATE PROCEDURE dbo.sp_AvgWeeklyChangeInCOVIDDeaths
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    WITH WeeklyChanges AS (
        SELECT 
            Jurisdiction_Residence,
            data_period_start,
            data_period_end,
            COVID_deaths,
            LAG(COVID_deaths) OVER (
                PARTITION BY Jurisdiction_Residence ORDER BY data_period_start
            ) AS Prev_Week_Deaths
        FROM COVID_19_Death_Data
        WHERE data_period_start BETWEEN @StartDate AND @EndDate
    )
    
    SELECT 
        wc.Jurisdiction_Residence,
        @StartDate AS Start_Date,
        @EndDate AS End_Date,
        AVG(
            CASE 
                WHEN Prev_Week_Deaths IS NULL OR Prev_Week_Deaths = 0 THEN NULL
                ELSE ((COVID_deaths - Prev_Week_Deaths) / Prev_Week_Deaths) * 100
            END
        ) AS Avg_Weekly_Percent_Change,
        dbo.fn_AvgCrudeCOVIDRate(wc.Jurisdiction_Residence) AS Avg_Crude_COVID_Rate
    FROM WeeklyChanges wc
    GROUP BY wc.Jurisdiction_Residence;
END;

---Execute the Procedure
EXEC dbo.sp_AvgWeeklyChangeInCOVIDDeaths @StartDate = '2022-01-01', @EndDate = '2022-12-31';
