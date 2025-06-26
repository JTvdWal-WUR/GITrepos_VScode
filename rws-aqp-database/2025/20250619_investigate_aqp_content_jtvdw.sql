-- 20250619, Jan Tjalling van der Wal
-- Finding out which species occur within 
-- what monitoring programme, gear, krw_waterlichaam , year.
-- This is informative and useful for users that e.g. want to 
-- compare Length-Frequencies across these categories.
-- This can save them a lot of time looking for data that is available.

-- Aggregate=TRUE
-- SELECT distinct _a_programma as programme, a_krwlichaam as wmr_waterbody_krw, 
-- a_tuig as gear, a_jaar as coll_year, a_soort as soort, a_scient_name as scient_name, aggregate
-- FROM aqp.api_measurements 
-- where aggregate=TRUE -- and id like 'a.IN.%'
-- ;
-- OUCH, 51511 rows at present, a lot more then I had expected.
-- Aha, to get a more sensible number of results (far fewer), it makes sense to exclude
-- lengte-frequentie resultaten (id not like 'a.LF.%') -- Just under 1500 rows less: 50099

-- Aggregate=FALSE
-- SELECT distinct _pgm_code as programme , wmr_waterbody_krw, samplingdevice as gear, 
-- extract(year from collectiondate) as coll_year, 'nl_naam' as soort, parameter as scient_name, aggregate --, 
-- FROM aqp.api_measurements
-- where aggregate=FALSE 
--limit 1000
-- ;

-- Weird. Just 119 rows for this query. And year is NULL for all of those! 
-- Found asked for parametertype instead of parameter as scient_name: 17767 results after fix. 
-- "year" (a reserved word?) is always NULL where aggrate=FALSE. 
-- It can be created by using this instead: extract(year from collectiondate)
-- 
-- Including a 'reconstituted' year in the query increase the number of results to 1159
-- select distinct "year" FROM aqp.api_measurements
-- where aggregate=FALSE ; -- always NULL!
-- select distinct wmr_collectiondate_original FROM aqp.api_measurements
-- where aggregate=FALSE ; -- always NULL!
-- select distinct extract(year from collectiondate)FROM aqp.api_measurements
-- where aggregate=FALSE ; -- 35 rows 1989 thru 2023 . 

-- select count(*) FROM aqp.api_measurements
-- where aggregate=FALSE --and collectiondate is not null; 
-- collectiondate is NULL: zero results
-- collectiondate is not null: 2712319 results same as for just aggregate=FALSE. 
-- So every row that is raw (aggregate=FALSE) has a collectiondate. 
-- select extract(year from NULL::date); -- NULL

--
-- SELECT 
-- -- id, 
-- distinct left(id,5), aggregate
-- FROM aqp.api_measurements 
-- where aggregate=TRUE-- and id not like 'a.LF.%'
-- ; 
-- left
-- a.LF.
-- a.AJ.
-- a.IN.

-- SELECT id, changedate, organisation, sourcesystem, aggregate, 
-- _a_path, _a_programma, a_krwlichaam, a_gebied, a_tuig, a_jaar,
-- a_scient_name, a_soort, a_weight, _a_voorkomen, _a_number, a_eenheid, 
-- a_inspanning, a_lengte,a_habitat, a_cpue, a_cpue_eenheid, a_cpue_w, a_cpue_w_eenheid
-- FROM aqp.api_measurements 
-- where aggregate=TRUE and id like 'a.LF.%';

-- SELECT id, changedate, aggregate, 
-- _a_programma, a_krwlichaam, a_gebied, a_tuig, a_jaar,
-- a_scient_name, a_soort, _a_number, a_eenheid, 
-- a_lengte,a_habitat, a_cpue, a_cpue_eenheid, a_cpue_w, a_cpue_w_eenheid
-- FROM aqp.api_measurements 
-- where aggregate=TRUE and id like 'a.LF.%';

-- with preview as (
-- SELECT distinct _a_programma as programme, a_krwlichaam as wmr_waterbody_krw, 
-- a_tuig as gear, a_jaar as coll_year, a_soort as soort, a_scient_name as scient_name, aggregate
-- FROM aqp.api_measurements 
-- where aggregate=TRUE 
-- UNION
-- SELECT distinct _pgm_code as programme , wmr_waterbody_krw, samplingdevice as gear, 
-- extract(year from collectiondate) as coll_year, 'nl_naam' as soort, parameter as scient_name, aggregate --, 
-- FROM aqp.api_measurements
-- where aggregate=FALSE )

-- select distinct soort, scient_name, programme, gear, aggregate from preview 
-- where scient_name is null or scient_name = '';

-- create view aqp.aqp_overview as
-- SELECT distinct _a_programma as programme, a_krwlichaam as wmr_waterbody_krw, 
-- a_tuig as gear, a_jaar as coll_year, a_soort as soort, a_scient_name as scient_name, aggregate
-- FROM aqp.api_measurements 
-- where aggregate=TRUE 
-- UNION
-- SELECT distinct _pgm_code as programme , wmr_waterbody_krw, samplingdevice as gear, 
-- extract(year from collectiondate) as coll_year, 'nl_naam' as soort, parameter as scient_name, aggregate --, 
-- FROM aqp.api_measurements
-- where aggregate=FALSE;

-- select * from aqp.aqp_overview;

-- grant select on aqp.aqp_overview to aqp;

-- select * from aqp.aqp_overview
-- where wmr_waterbody_krw = 'Volkerak' and gear = 'Boomkor';
-- Should be OK for DD-API, Volkerak and gear=Boomkor seems unique without a programme (always FGRA in this case).

-- select * from aqp.aqp_overview
-- where wmr_waterbody_krw = 'IJsselmeer' and gear = 'Boomkor';
-- Should be OK for DD-API, Volkerak and gear=Boomkor seems unique without a programme (always FYMA in this case).

-- select * from aqp.aqp_overview
-- where wmr_waterbody_krw = 'IJsselmeer' and gear like '%uik%' and scient_name = 'Salmo salar' and aggregate = TRUE;
-- Should be OK for DD-API, Volkerak and gear=Boomkor seems unique without a programme (always FDIA in this case).
-- select * from aqp.aqp_overview
-- where wmr_waterbody_krw = 'IJsselmeer' and gear like '%uik%' and scient_name = 'Salmo salar';
-- FGRF does also catch salmon in Lake IJssel, but these data are apparently no aggrated to e.g. LF-results.

-- select * from aqp.aqp_overview
-- where scient_name = 'Sander lucioperca' and wmr_waterbody_krw = 'IJsselmeer' and aggregate = TRUE and gear = 'Zegen';
-- Should be OK for DD-API, IJsselmeer, Sander and zegen is unique without a programme (always FYOE in this case).
-- select * from aqp.aqp_overview
-- where scient_name = 'Sander lucioperca' and wmr_waterbody_krw = 'IJsselmeer' and aggregate = TRUE and gear = 'Kuil';
-- Should be OK for DD-API, IJsselmeer, Sander and kuil is unique without a programme (always FYMA in this case).
-- select * from aqp.aqp_overview
-- where scient_name = 'Sander lucioperca' and wmr_waterbody_krw = 'IJsselmeer' and aggregate = TRUE and gear = 'fuik';
-- Should be OK for DD-API, IJsselmeer, Sander and fuik is unique without a programme (always FDIA in this case).
-- select * from aqp.aqp_overview
-- where scient_name = 'Sander lucioperca' and wmr_waterbody_krw = 'IJsselmeer' and aggregate = TRUE and gear = 'Elektrokor';
-- Should be OK for DD-API, IJsselmeer, Sander and elektrokor is unique without a programme (always FYMA in this case).
-- select * from aqp.aqp_overview
-- where scient_name = 'Sander lucioperca' and wmr_waterbody_krw = 'IJsselmeer' and aggregate = TRUE and gear = 'Elektroschepnet';
-- Should be OK for DD-API, IJsselmeer, Sander and elektroschepnet is unique without a programme (always FYOE in this case).

-- select distinct wmr_waterbody_krw, gear, scient_name, soort from aqp.aqp_overview
-- where aggregate = true
-- order by scient_name, soort, gear
-- ;
-- 3629 rows returned, 3676 after adding soort (nl_naam as well)
-- select distinct programme, wmr_waterbody_krw, gear, scient_name, soort from aqp.aqp_overview
-- where aggregate = true
-- order by scient_name, soort,gear
-- ;
-- 3680 rows returned, expected 3629. 3727 after adding soort (nl_naam)

-- with zonder_programma AS
-- (
-- select distinct wmr_waterbody_krw, gear, scient_name, soort from aqp.aqp_overview
-- where aggregate = true
-- ),
-- met_programma as 
-- (
-- select distinct programme, wmr_waterbody_krw, gear, scient_name, soort from aqp.aqp_overview
-- where aggregate = true
-- )
-- select * from met_programma m 
--     left outer join zonder_programma z
--     on 
--     m.wmr_waterbody_krw = z.wmr_waterbody_krw and
--     m.gear = z.gear and
--     m.scient_name = z.scient_name and
--     m.soort = z.soort
-- order by z.wmr_waterbody_krw, z.gear, z.scient_name, z.soort;

