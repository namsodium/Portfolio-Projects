-- Examining the entire data
select *
from PortfolioProject.drugs;

/*
Examining Marijuana Usage
*/

-- Checking how number of new marijuana users per age group changes every year (For all the states together)

-- Raw Numbers
select Year, sum(`Population.12-17`) `Total Population.12-17`,
			 sum(`Population.18-25`) `Total Population.18-25`,
             sum(`Population.26+`) `Total Population.26+`,
             sum(`Totals.Marijuana.New Users.12-17`)*1000 `Totals.Marijuana.New Users.12-17`,
             sum(`Totals.Marijuana.New Users.18-25`)*1000 `Totals.Marijuana.New Users.18-25`,
             sum(`Totals.Marijuana.New Users.26+`)*1000 `Totals.Marijuana.New Users.26+`
from PortfolioProject.drugs
group by Year
order by Year;

-- As a percentage of total population of specific age group
select Year, sum(`Population.12-17`) `Total Population.12-17`,
			 sum(`Population.18-25`) `Total Population.18-25`,
             sum(`Population.26+`) `Total Population.26+`,
             (sum(`Totals.Marijuana.New Users.12-17`)*100000)/sum(`Population.12-17`) `Percent.Marijuana.New Users.12-17`,
             (sum(`Totals.Marijuana.New Users.18-25`)*100000)/sum(`Population.18-25`) `Percent.Marijuana.New Users.18-25`,
             (sum(`Totals.Marijuana.New Users.26+`)*100000)/sum(`Population.26+`) `Percent.Marijuana.New Users.26+`
from PortfolioProject.drugs
group by Year
order by Year;

-- creating views to visualize

-- Raw numbers
drop view if exists TotalPopulationNewMarijuanaUsers;
create view TotalPopulationNewMarijuanaUsers as
select Year, sum(`Population.12-17`) `Total Population.12-17`,
			 sum(`Population.18-25`) `Total Population.18-25`,
             sum(`Population.26+`) `Total Population.26+`,
             sum(`Totals.Marijuana.New Users.12-17`)*1000 `Totals.Marijuana.New Users.12-17`,
             sum(`Totals.Marijuana.New Users.18-25`)*1000 `Totals.Marijuana.New Users.18-25`,
             sum(`Totals.Marijuana.New Users.26+`)*1000 `Totals.Marijuana.New Users.26+`,
             (sum(`Totals.Marijuana.New Users.12-17`)*1000) + 
             (sum(`Totals.Marijuana.New Users.18-25`)*1000) + 
             (sum(`Totals.Marijuana.New Users.26+`)*1000) `Total New Marijuana Users`
from PortfolioProject.drugs
group by Year
order by Year;

-- Percentage
drop view if exists PercentPopulationNewMarijuanaUsers;
create view PercentPopulationNewMarijuanaUsers as
select Year, sum(`Population.12-17`) `Total Population.12-17`,
			 sum(`Population.18-25`) `Total Population.18-25`,
             sum(`Population.26+`) `Total Population.26+`,
             (sum(`Totals.Marijuana.New Users.12-17`)*100000)/sum(`Population.12-17`) `Percent.Marijuana.New Users.12-17`,
             (sum(`Totals.Marijuana.New Users.18-25`)*100000)/sum(`Population.18-25`) `Percent.Marijuana.New Users.18-25`,
             (sum(`Totals.Marijuana.New Users.26+`)*100000)/sum(`Population.26+`) `Percent.Marijuana.New Users.26+`,
             ((sum(`Totals.Marijuana.New Users.12-17`)*100000)/sum(`Population.12-17`)) + 
             ((sum(`Totals.Marijuana.New Users.18-25`)*100000)/sum(`Population.18-25`)) + 
             ((sum(`Totals.Marijuana.New Users.26+`)*100000)/sum(`Population.26+`)) `Percent New Marijuana Users`
from PortfolioProject.drugs
group by Year
order by Year;

-- export to visualize in tableau
select *
from TotalPopulationNewMarijuanaUsers;

select *
from PercentPopulationNewMarijuanaUsers;

-- Checking Marijuana Stats Per State
select State,
	   sum(`Totals.Marijuana.Used Past Year.12-17`)*1000 `Total Number of People Who Used Marijuana.12-17`, 
       sum(`Totals.Marijuana.Used Past Year.18-25`)*1000 `Total Number of People Who Used Marijuana.18-25`,
       sum(`Totals.Marijuana.Used Past Year.26+`)*1000 `Total Number of People Who Used Marijuana.26+`,
       sum(`Totals.Marijuana.Used Past Year.12-17`)*1000 + 
       sum(`Totals.Marijuana.Used Past Year.18-25`)*1000 + 
       sum(`Totals.Marijuana.Used Past Year.26+`)*1000 `Total Number of People Who Used Marijuana`,
       sum(`Totals.Marijuana.New Users.12-17`)*1000 `Totals.Marijuana.New Users.12-17`, 
       sum(`Totals.Marijuana.New Users.18-25`)*1000 `Totals.Marijuana.New Users.18-25`,
       sum(`Totals.Marijuana.New Users.26+`)*1000 `Totals.Marijuana.New Users.26+`,
       sum(`Totals.Marijuana.New Users.12-17`)*1000 +
       sum(`Totals.Marijuana.New Users.18-25`)*1000 +
       sum(`Totals.Marijuana.New Users.26+`)*1000 `Totals.Marijuana.New Users`
       
       
from PortfolioProject.drugs
group by State;

-- creating view and exporting
drop view if exists StateWiseMarijuanaStats;
create view StateWiseMarijuanaStats as
select State,
	   sum(`Totals.Marijuana.Used Past Year.12-17`)*1000 `Total Number of Times Marijuana Was Used.12-17`, 
       sum(`Totals.Marijuana.Used Past Year.18-25`)*1000 `Total Number of People Who Used Marijuana.18-25`,
       sum(`Totals.Marijuana.Used Past Year.26+`)*1000 `Total Number of People Who Used Marijuana.26+`,
       sum(`Totals.Marijuana.Used Past Year.12-17`)*1000 + 
       sum(`Totals.Marijuana.Used Past Year.18-25`)*1000 + 
       sum(`Totals.Marijuana.Used Past Year.26+`)*1000 `Total Number of People Who Used Marijuana`,
       sum(`Totals.Marijuana.New Users.12-17`)*1000 `Totals.Marijuana.New Users.12-17`, 
       sum(`Totals.Marijuana.New Users.18-25`)*1000 `Totals.Marijuana.New Users.18-25`,
       sum(`Totals.Marijuana.New Users.26+`)*1000 `Totals.Marijuana.New Users.26+`,
       sum(`Totals.Marijuana.New Users.12-17`)*1000 +
       sum(`Totals.Marijuana.New Users.18-25`)*1000 +
       sum(`Totals.Marijuana.New Users.26+`)*1000 `Totals.Marijuana.New Users`
       
       
from PortfolioProject.drugs
group by State;

select *
from StateWiseMarijuanaStats;


-- Comparing some stats of the different kinds of drugs being used
select State, Year,
	   sum(`Totals.Alcohol.Use Disorder Past Year.12-17`*1000) `Total Number of People with Alcohol Use Disorder.12-17`,
       sum(`Totals.Alcohol.Use Disorder Past Year.18-25`*1000) `Total Number of People with Alcohol Use Disorder.18-25`,
       sum(`Totals.Alcohol.Use Disorder Past Year.26+`*1000) `Total Number of People with Alcohol Use Disorder.26+`,
	   sum(`Totals.Alcohol.Use Disorder Past Year.12-17`*1000) +
	   sum(`Totals.Alcohol.Use Disorder Past Year.18-25`*1000) +
	   sum(`Totals.Alcohol.Use Disorder Past Year.26+`*1000) `Total Number of People with Alcohol Use Disorder`,
       sum(`Totals.Marijuana.Used Past Year.12-17`)*1000 `Total Number of People Who Used Marijuana.12-17`, 
       sum(`Totals.Marijuana.Used Past Year.18-25`)*1000 `Total Number of People Who Used Marijuana.18-25`,
       sum(`Totals.Marijuana.Used Past Year.26+`)*1000 `Total Number of People Who Used Marijuana.26+`,
       sum(`Totals.Marijuana.Used Past Year.12-17`)*1000 + 
       sum(`Totals.Marijuana.Used Past Year.18-25`)*1000 + 
       sum(`Totals.Marijuana.Used Past Year.26+`)*1000 `Total Number of People Who Used Marijuana`,
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.12-17`)*1000 `Total Number of People Who Used Cocaine.12-17`,
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.18-25`)*1000 `Total Number of People Who Used Cocaine.18-25`,
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.26+`)*1000  `Total Number of People Who Used Cocaine.26+`,
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.12-17`)*1000 + 
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.18-25`)*1000 + 
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.26+`)*1000 `Total Number of People Who Used Cocaine`

from PortfolioProject.drugs
group by State, Year
order by Year;

-- Creating view
drop view if exists DrugsComparison;
create view DrugsComparison as
select State, Year,
	   sum(`Totals.Alcohol.Use Disorder Past Year.12-17`*1000) `Total Number of People with Alcohol Use Disorder.12-17`,
       sum(`Totals.Alcohol.Use Disorder Past Year.18-25`*1000) `Total Number of People with Alcohol Use Disorder.18-25`,
       sum(`Totals.Alcohol.Use Disorder Past Year.26+`*1000) `Total Number of People with Alcohol Use Disorder.26+`,
	   sum(`Totals.Alcohol.Use Disorder Past Year.12-17`*1000) +
	   sum(`Totals.Alcohol.Use Disorder Past Year.18-25`*1000) +
	   sum(`Totals.Alcohol.Use Disorder Past Year.26+`*1000) `Total Number of People with Alcohol Use Disorder`,
       sum(`Totals.Marijuana.Used Past Year.12-17`)*1000 `Total Number of People Who Used Marijuana.12-17`, 
       sum(`Totals.Marijuana.Used Past Year.18-25`)*1000 `Total Number of People Who Used Marijuana.18-25`,
       sum(`Totals.Marijuana.Used Past Year.26+`)*1000 `Total Number of People Who Used Marijuana.26+`,
       sum(`Totals.Marijuana.Used Past Year.12-17`)*1000 + 
       sum(`Totals.Marijuana.Used Past Year.18-25`)*1000 + 
       sum(`Totals.Marijuana.Used Past Year.26+`)*1000 `Total Number of People Who Used Marijuana`,
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.12-17`)*1000 `Total Number of People Who Used Cocaine.12-17`,
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.18-25`)*1000 `Total Number of People Who Used Cocaine.18-25`,
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.26+`)*1000  `Total Number of People Who Used Cocaine.26+`,
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.12-17`)*1000 + 
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.18-25`)*1000 + 
       sum(`Totals.Illicit Drugs.Cocaine Used Past Year.26+`)*1000 `Total Number of People Who Used Cocaine`

from PortfolioProject.drugs
group by State, Year
order by Year;

select *
from DrugsComparison;

select max(`Total Number of People Who Used Cocaine`), State
from DrugsComparison
group by State;
