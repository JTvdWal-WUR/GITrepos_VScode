-- 20250714_lf_condensor.sql
-- 20250714, JTvdWal
-- Condensing non-integer a_lengte values to integer values
-- in aid of the DD-API v3 requirements (Geri Wolters @ EcoSys on behalf RWS).
-- This script is to be run on multiple databases 
-- development has been done against the following database: opostgreswmr.aqpprod_aws5432.
-- Repeats are expected for a.o. the AWS-source, wmr-local aqp (opostgres)
-- and possibly ppostgres-version of these. 
--
-- PREREQUISITE: 20250728_aggregates_add_scientific_names.sql must have been run first!
-- Check select, expected result EQ no rows returned.
select a_scient_name from aqp.api_measurements where a_scient_name = '' and aggregate = true and id like 'a.LF.%';
--
with slct_non_integer_a_lengte as
(select id, sourcesystem, _a_path, _a_mapper, _a_programma, a_krwlichaam, a_tuig,
 a_jaar, a_scient_name, _a_number, a_lengte, a_cpue, a_cpue_w, a_eenheid
 from aqp.api_measurements 
 where 
 id like 'a.LF.%' 
 and a_lengte != a_lengte::integer
),
slct_target_rows as (
select distinct _a_programma, a_krwlichaam, a_tuig, a_scient_name 
from slct_non_integer_a_lengte
order by _a_programma, a_krwlichaam, a_tuig, a_scient_name)
select * from slct_target_rows; 
-- 20250714, JTvdWal 61 results as expected for opostgreswmr.aqpprod_aws5432
-- 20250728, JTvdWal 65 results from opostgreswmr.aqpprod_aws5432, a few more now
-- that the scientific names have been added to the aggregates.

-- _a_programma is in ('FYMA', 'WAV') !!!

-- select 
-- 	-- m.status, m.sourcesystem, -- not these
-- 	-- m.compartment, m.measurementpackage, -- any of these will do
-- 	-- m.measurementpurpose, m.methods, -- any of these will do
-- 	-- looking for a blank field (non-aggragate) to store a temp-value
-- 	-- picking m.measurementpurpose  
-- 	m.a_krwlichaam, m._a_programma, m.a_tuig, m.a_jaar, m.a_scient_name,
-- 	m.a_lengte, m.a_cpue, m.a_cpue_w, m.id 
-- from aqp.api_measurements m join slct_target_rows t on
-- 	m.a_krwlichaam = t.a_krwlichaam and
-- 	m._a_programma = t._a_programma and
-- 	m.a_tuig = t.a_tuig and
-- 	m.a_scient_name = t.a_scient_name
-- 	where 	
-- 	aggregate = true
-- 	and id like 'a.LF.%'
--  -- 189095 results for this query seems plausible

with slct_non_integer_a_lengte as
(select id, sourcesystem, _a_path, _a_mapper, _a_programma, a_krwlichaam, a_tuig,
 a_jaar, a_scient_name, _a_number, a_lengte, a_cpue, a_cpue_w, a_eenheid
 from aqp.api_measurements 
 where 
 id like 'a.LF.%' 
 and a_lengte != a_lengte::integer
),
slct_target_rows as (
select distinct _a_programma, a_krwlichaam, a_tuig, a_scient_name 
from slct_non_integer_a_lengte
order by _a_programma, a_krwlichaam, a_tuig, a_scient_name)
select 
	-- m.status, m.sourcesystem, -- not these
	-- m.compartment, m.measurementpackage, -- any of these will do
	-- m.measurementpurpose, m.methods, -- any of these will do
	-- looking for a blank field (non-aggregate) to store a temp-value
	-- picking m.measurementpurpose  
	'condens_lf_to_int(cm)' as measurementpurpose,
	m.a_krwlichaam, m._a_programma, m.a_tuig, m.a_jaar, m.a_scient_name, m.a_soort,
	m.a_lengte, m.a_cpue, m.a_cpue_w, m.id 
from aqp.api_measurements m join slct_target_rows t on
	m.a_krwlichaam = t.a_krwlichaam and
	m._a_programma = t._a_programma and
	m.a_tuig = t.a_tuig and
	m.a_scient_name = t.a_scient_name
	where 	
	aggregate = true
	and id like 'a.LF.%';
-- #DONE_1: make an update statement from the above to set this subset apart.
with slct_non_integer_a_lengte as
(select id, sourcesystem, _a_path, _a_mapper, _a_programma, a_krwlichaam, a_tuig,
 a_jaar, a_scient_name, _a_number, a_lengte, a_cpue, a_cpue_w, a_eenheid
 from aqp.api_measurements 
 where 
 id like 'a.LF.%' 
 and a_lengte != a_lengte::integer
),
slct_target_rows as (
select distinct _a_programma, a_krwlichaam, a_tuig, a_scient_name 
from slct_non_integer_a_lengte
order by _a_programma, a_krwlichaam, a_tuig, a_scient_name)
update aqp.api_measurements
set measurementpurpose = 'condens_lf_to_int(cm)'
where id in (
	select m.id
	from aqp.api_measurements m join slct_target_rows t on
		m.a_krwlichaam = t.a_krwlichaam and
		m._a_programma = t._a_programma and
		m.a_tuig = t.a_tuig and
		m.a_scient_name = t.a_scient_name
	where
		aggregate = true
		and id like 'a.LF.%'
);

-- #DONE_2: make an insert statement to create a fresh set of records with a_lengte as integer using floor().
with slct_non_integer_a_lengte as
(select id, sourcesystem, _a_path, _a_mapper, _a_programma, a_krwlichaam, a_tuig,
 a_jaar, a_scient_name, a_lengte, a_cpue, a_cpue_w, a_eenheid
 from aqp.api_measurements 
 where 
 id like 'a.LF.%' 
 and a_lengte != a_lengte::integer
),
slct_target_rows as (
select distinct _a_programma, a_krwlichaam, a_tuig, a_scient_name 
from slct_non_integer_a_lengte
order by _a_programma, a_krwlichaam, a_tuig, a_scient_name)
insert into aqp.api_measurements (id, sourcesystem, _a_path, _a_mapper, _a_programma, a_krwlichaam, a_tuig,
 a_jaar, a_scient_name, a_soort, a_lengte, a_cpue, a_cpue_w, a_eenheid, measurementpurpose, 
 aggregate, a_cpue_eenheid, a_cpue_w_eenheid, changedate, organisation, status)
select min(id)||'_cdn', min(sourcesystem), min(_a_path), min(_a_mapper), _a_programma, a_krwlichaam, a_tuig,
 a_jaar, a_scient_name, a_soort, floor(a_lengte), sum(a_cpue), sum(a_cpue_w), a_eenheid, 'condensed_lf_to_int(cm)', 
 true, min(a_cpue_eenheid), min(a_cpue_w_eenheid), min(changedate), min (organisation), min(status)
from aqp.api_measurements
where id in (
	select m.id
	from aqp.api_measurements m join slct_target_rows t on
		m.a_krwlichaam = t.a_krwlichaam and
		m._a_programma = t._a_programma and
		m.a_tuig = t.a_tuig and
		m.a_scient_name = t.a_scient_name
	where
		aggregate = true
		and id like 'a.LF.%'
)
GROUP BY _a_programma, a_krwlichaam, a_tuig, a_jaar, a_scient_name, a_soort, floor(a_lengte), a_eenheid;
-- adding ||'c' to min(id) to make sure the new id's are unique.

-- Checking the results of the above insert
select id, sourcesystem, _a_path, _a_mapper, _a_programma, a_krwlichaam, a_tuig,
 a_jaar, a_scient_name, a_soort, a_lengte, a_cpue, a_cpue_w, a_eenheid, a_cpue_eenheid, a_cpue_w_eenheid, changedate, 
 status, organisation, measurementpurpose
from aqp.api_measurements
where 	aggregate = true
		and id like 'a.LF.%'
		and measurementpurpose = 'condensed_lf_to_int(cm)'	;

select distinct measurementpurpose from aqp.api_measurements
where id like 'a.LF.%' and aggregate = true;
and measurementpurpose = 'condensed_lf_to_int(cm)';

-- sample query to check the results for a programma, year and species
-- FYMA, 2010, Osmerus eperlanus
-- While retained this should yield both the source and the condensed data.
select * from aqp.api_measurements where _a_programma = 'FYMA' and a_jaar = 2010 and a_scient_name = 'Osmerus eperlanus'
order by measurementpurpose, a_lengte;

-- DELETE (temporary result) from incomplete insert-statement(s)
-- delete from aqp.api_measurements where measurementpurpose = 'condensed_lf_to_int(cm)';
-- no id or aggregate as part of the where-clause, these where omitted (== error)

-- #DONE_3: make a delete statement to set remove the subset where measurementpurpose = 'condens_lf_to_int(cm)'.
-- delete from aqp.api_measurements where measurementpurpose = 'condens_lf_to_int(cm)';
-- N.B. NOT YET RUN, uncondensed data retained for checking purposes.
