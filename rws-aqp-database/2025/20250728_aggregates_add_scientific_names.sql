-- 202507278, Jan Tjalling van der Wal
-- Add scientific names to the aggregated subset of data where missing!
-- N.B. Needs to be run before 20250714_lf_condensor.sql
-- otherwise that will miss required information.

-- set autocommit = off; -- not recognised in vs-code+postgresql-plugin.

update aqp.api_measurements
set a_scient_name = 'Clupeidae'
where lower(a_soort) = 'clupeidae' and a_scient_name = '';

update aqp.api_measurements
set a_scient_name = 'Clupeidae'
where a_soort = 'haring/sprot' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Pomatoschistus minutus'
where a_soort = 'dikkopje' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Chirolophis ascanii'
where a_soort = 'franjekop' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Mustelus mustelus'
where a_soort = 'gladde haai' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Knipowitschia caucasica'
where a_soort = 'kaukasische dwerggrondel' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Pomatoschistus lozanoi'
where a_soort = 'lozanos grondel' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Ammodytes tobianus'
where a_soort = 'kleine zandspiering' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Ammodytes marinus'
where a_soort = 'noorse zandspiering' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Hippocampus hippocampus'
where a_soort = 'kortsnuitzeepaardje' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Hippocampus guttulatus'
where a_soort = 'zeepaardje' and a_scient_name ='';

update aqp.api_measurements
set a_scient_name = 'Lepidorhombus whiffiagonis'
where a_soort = 'scharretong' and a_scient_name = '';

update aqp.api_measurements
set a_scient_name = 'Sprattus sprattus'
where a_soort = 'sprot' and a_scient_name = '';

update aqp.api_measurements
set a_scient_name = 'Raja clavata'
where a_soort = 'stekelrog' and a_scient_name = '';

update aqp.api_measurements
set a_scient_name = 'Gnathostomata'
where a_soort = 'vissoort onbekend' and a_scient_name = '';

update aqp.api_measurements
set a_scient_name = 'Salmonidae'
where a_soort = 'zalmachtigen' and a_scient_name = '';

commit;

-- Check select 1: distinct aggregate names for length-frequency rows
-- expected: zero results
select distinct a_scient_name, a_soort 
from aqp.api_measurements 
where a_scient_name = '' and aggregate = true and id like 'a.LF.%';
-- Check select 2: non-discrete aggregate names for length-frequency rows
-- expected: zero results
select a_scient_name, a_soort 
from aqp.api_measurements 
where a_scient_name = '' and aggregate = true and id like 'a.LF.%';
-- Check select 3
-- hopefully also zero results
select distinct a_scient_name, a_soort 
from aqp.api_measurements 
where a_scient_name = '' and aggregate = true;  

-- checks 1,2 and 3 as expected i.e. no results
