use portfoli_db;

select * from dataset1;
select * from dataset2;
-- Number of rows in our dataset

select count(*) from dataset1;
select count(*) from dataset2;
-- dataset for jharkand and bihar

select * from dataset1 where state in ("Jharkand", "Bihar");

select * from dataset2;
select sum(Population) as total_population from dataset2;

select state,avg(Growth)*100 as avg_growth from dataset1 group by State;

select State, round(avg(Sex_ratio),0) as avgsexratio, avg(Growth)*100 from dataset1 group by State order by avgsexratio desc;

select State, round(avg(Literacy),0) as avgLiteracy, round(avg(Growth)*100,0) 
from dataset1 
group by State 
having avgLiteracy > 90
order by avgLiteracy desc ;

-- Top 3 states showing higest growth ratio
select State, avg(growth)*100 as avg_growth
from dataset1
group by state 
order by avg_growth desc limit 3;

-- Bottom 3 states showing lowest sex ratio
select State, round(avg(Sex_Ratio),0) as avg_sexratio
from dataset1
group by state 
order by  avg_sexratio asc limit 3;

-- top and bottom 3 states literacy state

create table topstates(
state varchar(255),
topstates float);

insert into topstates
select State, round(avg(literacy),0) as avg_literacy_ratio 
from dataset1
group by state 
order by avg_literacy_ratio desc;

select * from topstates;

-- top 3 states
select * from topstates 
order by topstates desc limit 3;

-- bottom 3 states
create table bottomstates(
state varchar(255),
bottomstates float);

insert into bottomstates
select State, round(avg(literacy),0) as avg_literacy_ratio 
from dataset1
group by state 
order by avg_literacy_ratio asc;

select * from bottomstates;
-- bottom  3 states
select * from bottomstates 
order by bottomstates asc limit 3;

-- joining tables to display both top and bottom states 

select * from (select * from topstates order by topstates desc limit 3) a
UNION
select * from (select * from bottomstates order by bottomstates asc limit 3) b;

-- states starting with letter a 

select distinct state from dataset1 where lower(state) like 'a%' or lower(state) like 'b%' ;

select distinct state from dataset1 where lower(state) like 'a%' and lower(state) like '%h' ;

-- joining tables
select d.state, sum(d.males) as total_males, sum(d.females) as total_females from (
select c.district, c.state,round(c.population/(c.Sex_Ratio+1),0) as males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as females from 
(select a.state, a.district, a.Sex_Ratio/1000 as Sex_ratio, b.Population from dataset1 a
inner join dataset2 b
on a.district = b.district) c) d
group by d.state;

--  female / males = sex ratio ....... 1
-- females + males = population ...... 2
-- females = population - males ...... 3
-- (population - males) = (sex_ratio) * males
-- populatio = males (sex_ratio+1)
-- males = population/(sex_ratio+1) .....males
-- females = population-(population/(sex_ratio+1)) .... females
-- = population(1-1/(sex_ratio+1)
-- = (population(sex_ratio))/ (sex_ratio + 1)

-- total literact rate
-- total literate people/ population-literacy ratio

select a.district, a.state, a.literacy as literacy_ratio,b.population from dataset1 a inner join dataset2 b 
on a.district=b.district;

-- total literate people = literacy ratio*population
-- total illterate people = (1- literacy _ratio)*population
select c.state,sum(literate_people) as total_literate_pop, sum(illterate_people) as total_illiterate_pop from(
select d.district,d.state,round(d.literacy_ratio*d.population,0) as literate_people, round((1-literacy_ratio)*d.population,0) as illterate_people from
(select a.district, a.state, a.literacy/100 as literacy_ratio,b.population from dataset1 a inner join dataset2 b 
on a.district=b.district) d) c
group by c.state ;

-- population in previuos census 
-- previous_census+growth*previous_census = population 
-- previous_census=population/(1+growth)

select sum(m.previous_census_population) as previous_census_population_vs_area, sum(m.current_census_population) as current_census_population_vs_area FROM (
select e.state, sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population from
(select d.district, d.state, round(d.population/(1+growth),0) as previous_census_population,d.population as current_census_population from
(select a.district,a.state,a.growth as growth, b.Population from dataset1 a inner join dataset2 b on a.district=b.district) d) e
group by e.state) m;

-- windows function

select a.* from 
(select district, state, literacy, rank() over (partition by state order by literacy desc) rnk from dataset1 ) a
where a.rnk in (1,2,3) order by state;
