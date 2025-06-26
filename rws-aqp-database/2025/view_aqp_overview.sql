create view aqp.aqp_overview as
SELECT distinct _a_programma as programme, a_krwlichaam as wmr_waterbody_krw, 
a_tuig as gear, a_jaar as coll_year, a_soort as soort, a_scient_name as scient_name, aggregate
FROM aqp.api_measurements 
where aggregate=TRUE 
UNION
SELECT distinct _pgm_code as programme , wmr_waterbody_krw, samplingdevice as gear, 
extract(year from collectiondate) as coll_year, 'nl_naam' as soort, parameter as scient_name, aggregate --, 
FROM aqp.api_measurements
where aggregate=FALSE;

grant select on aqp.aqp_overview to aqp;