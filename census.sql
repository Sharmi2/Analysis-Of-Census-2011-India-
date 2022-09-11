--Display table "Population_Districtwise
SELECT *
FROM census..population_districtwise WHERE State LIKE '#N/A'

--Display table "Literacy Rate"
SELECT *
FROM census..population

--Total Number of rows present in each table
SELECT COUNT(*) 
FROM census..population_districtwise
Select COUNT(*) 
FROM census..population

--Display Literacy rate for West Bengal and Orissa
SELECT *
FROM census..population WHERE state in ('West Bengal','Orissa')

--Average population growth of India
SELECT AVG(growth)*100 AS average_growth 
FROM census..population

--Average growth of population in each state
SELECT state,avg(growth)*100 AS avg_growth_statewise 
FROM census..population GROUP BY state

--Average sex ratio in each state in descending order
SELECT state,round(avg([Sex-Ratio]),0) AS avg_sexratio_statewise 
FROM census..population GROUP BY state order by avg_sexratio_statewise desc

--States having average literacy less than 70%
SELECT state,avg(literacy) AS avg_literacy_statewise 
FROM census..population GROUP BY state
HAVING round(avg(literacy),0) <70 
ORDER BY avg_literacy_statewise asc

--Top 3 states which have displayed highest growth in population
SELECT TOP 3 state,avg(growth)*100 AS Top_3_state_with_highest_growth 
FROM census..population GROUP BY state
ORDER BY Top_3_state_with_highest_growth desc

--Bottom 3 States showing lowest sex ratio
SELECT TOP 3 state,round(avg([Sex-Ratio]),0) AS avg_sexratio_statewise 
FROM census..population GROUP BY state order by avg_sexratio_statewise asc

--Create a tempoerary table to displaye the top 3 states with highest literacy rate
DROP TABLE IF EXISTS #literacyrateshigh
CREATE TABLE #literacyrateshigh
(state nvarchar(255),
literacyratehigh float

)
INSERT INTO #literacyrateshigh
SELECT state,round(avg(Literacy),0) AS avg_literacyrate_statewise 
FROM census..population GROUP BY state --order by avg_literacyrate_statewise desc

SELECT top 3 * 
FROM #literacyrateshigh ORDER BY literacyratehigh DESC

--Create a tempoerary table to displaye the bottom 3 states with lowest literacy rate
DROP TABLE IF EXISTS #literacyrateslow
CREATE TABLE #literacyrateslow
(state nvarchar(255),
literacyratelow float

)
INSERT INTO #literacyrateslow
SELECT state,round(avg(Literacy),0) AS avg_literacyrate_statewise 
FROM census..population GROUP BY state --order by avg_literacyrate_statewise desc

SELECT top 3 * 
FROM #literacyrateslow ORDER BY literacyratelow ASC

--Displaying 3 states with highest and lowest literacy rates
SELECT * FROM(
SELECT top 3 * 
FROM #literacyrateshigh ORDER BY literacyratehigh DESC) A
UNION
SELECT * FROM(
SELECT top 3 * 
FROM #literacyrateslow ORDER BY literacyratelow ASC) B

--Calculating the total no of male and female in each state

SELECT b.state, SUM(b.males) Total_Males, SUM(b.females) Total_Females FROM
(SELECT a.district, a.state, round((a.population/(a.[Sex-Ratio]/1000+1)),0) Males, (a.Population-(round((a.population/(a.[Sex-Ratio]/1000+1)),0))) Females
FROM census..population a INNER JOIN census..population b ON a.District=b.District) b
GROUP BY b.State

--Calculating the total no of literates in each state
SELECT b.state, SUM(b.Literates) Total_Literates, SUM(b.Illiterates) Total_Illiterates FROM
(SELECT a.district, a.state, a.Population, round((a.Literacy/100)*a.Population,0) Literates, (a.Population-round((a.Literacy/100)*a.Population,0)) Illiterates
FROM census..population a INNER JOIN census..population b ON a.District=b.District) b
GROUP BY b.State
--ORDER BY Total_Literates DESC

--Population in the previous census
SELECT SUM(b.Population_2011)Total_Population_2011, SUM(b.Population_2001) Total_Population_2001 FROM
(SELECT a.State, SUM(a.Population_2001) AS Population_2001,SUM(a.Population_2011) AS Population_2011 FROM
(SELECT District, State, Population AS Population_2011, round((Population/(1+Growth)),0) AS Population_2001
FROM census..population) a
GROUP BY a.State) b

--Population density of each state
SELECT a.State, round((a.Total_Population/a.Total_Area_km2),2) Population_Density FROM
(SELECT State, SUM(Area_km2) Total_Area_km2, SUM(Population) Total_Population
FROM census..population_districtwise
WHERE State !='#N/A'
GROUP BY State) a
ORDER BY Population_Density DESC

--Top 3 districts in each state whose literacy rates are highest
SELECT a.* FROM 
(SELECT District,State,Literacy,RANK() OVER(PARTITION BY STATE ORDER BY Literacy DESC) Rank 
FROM census..population) a
WHERE Rank IN (1,2,3) ORDER BY State












