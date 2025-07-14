-- 20250714_lf_condensor.sql
-- 20250714, JTvdWal
-- Condensing non-integer a_lengte values to integer values
-- in aid of the DD-API v3 requirements (Geri Wolters @ EcoSys on behalf RWS).
-- This script is to be run on multiple databases 
-- development has been done against the following database: opostgreswmr.aqpprod_aws5432.
-- Repeats are expected for a.o. the AWS-source, wmr-local aqp (opostgres)
-- and possibly ppostgres-version of these. 
--
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
-- select * from slct_target_rows; -- 20250714, JTvdWal 61 results as expected for opostgreswmr.aqpprod_aws5432
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
-- #TODO_1: make an update statement from the above to set this subset apart.
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

-- #TODO_2: make an insert statement creat a fresh set of records with a_lengte as integer using floor().
insert into aqp.api_measurements (id, sourcesystem, _a_path, _a_mapper, _a_programma, a_krwlichaam, a_tuig,
 a_jaar, a_scient_name, _a_number, a_lengte, a_cpue, a_cpue_w, a_eenheid, measurementpurpose)
select id, sourcesystem, _a_path, _a_mapper, _a_programma, a_krwlichaam, a_tuig,
 a_jaar, a_scient_name, _a_number, floor(a_lengte), a_cpue, a_cpue_w, a_eenheid, 'condens_lf_to_int(cm)'
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
);

-- #TODO_3: make a delete statement to set remove the subset where measurementpurpose = 'condens_lf_to_int(cm)'.
-- 
