-- This is helper sql to create src/sql/register_all_archiving.sql
-- The universe of _H tables is different in dev/stg/prd
-- The archiving start date may also differ
-- We will create [dev|stg|prd]_register_all_archiving scripts in June 2025
-- They will be called from batch files like @src/sql/%ENV%_register_all_archiving.sql
-- But who knows what will happen between now and whenever you are reading this
-- You reader will probably want to regenerate src/sql/xxx_register_all_archiving.sql
-- 
-- run as CSCL
-- output looks like 100+ 
-- call sde.register_archiving('ACCESSPOINTSTOENTRANCEPOINTS' ,'ACCESSPOINTSTOENTRANCEPOINTS_H' ,1399742968);
-- etc
--
select 
	'call sde.nyc_archive_utils.register_archiving(''' || c.table_name || ''' ,''' 
	                                 || b.table_name || ''' ,'
	                                 || a.archive_date || ');' 
from 
	sde.sde_archives a
join
	sde.table_registry b on a.history_regid = b.registration_id
join 
	sde.table_registry c on a.archiving_regid = c.registration_id
where 
	b.owner = 'CSCL'
and b.table_name in (
                     'ACCESSPOINT_H'
                    ,'ACCESSPOINTSTOENTRANCEPOINTS_H'
                    ,'ACCESSPOINTTOADDRESSPOINT4_H'
                    ,'ADDRESSPOINT_H'
                    ,'ADDRESSPOINTLGCS_H'
                    ,'ADJACENTBOROUGHBOUNDARY_H'
                    ,'ADMINBOUNDARIES_H'
                    ,'ALARMBOX_H'
                    ,'ALARMBOXAREA_H'
                    ,'ALTSEGMENTDATA_H'
                    ,'ASSEMBLYDISTRICT_H'
                    ,'ATOMICPOLYGON_H'
                    ,'BLOCKFACE_H'
                    ,'BOROUGH_H'
                    ,'BUSINESSIMPROVEMENTDISTRICT_H'
                    ,'CADSOURCEADDRESS_H'
                    ,'CELLULARCALLBOX_H'
                    ,'CENSUSBLOCK2000_H'
                    ,'CENSUSBLOCK2010_H'
                    ,'CENSUSTRACT1990_H'
                    ,'CENSUSTRACT2000_H'
                    ,'CENSUSTRACT2010_H'
                    ,'CENTERLINE_H1'
                    ,'CENTERLINEHISTORY_H'
                    ,'CITYCOUNCILDISTRICT_H'
                    ,'CITYLIMIT_H'
                    ,'COMMONPLACE_H'
                    ,'COMMONPLACEBULKLOADSTAGING_H'
                    ,'COMMONPLACESHAVEACCESSPOINTS_H'
                    ,'COMMONPLACESHAVEADDRESSPOIN_H'
                    ,'COMMONPLACESHAVEFEATURENAMES_H'
                    ,'COMMUNITYDISTRICT_H'
                    ,'COMPLEX_H'
                    ,'COMPLEXACCESSPOINT_H'
                    ,'COMPLEXINTERSECTION_H'
                    ,'CONGRESSIONALDISTRICT_H'
                    ,'DELETEDSTREETCODES_H'
                    ,'ELECTIONDISTRICT_H'
                    ,'ELEVATION_H'
                    ,'EMSATOM_H'
                    ,'EMSBATTALION_H'
                    ,'EMSDISPATCHAREA_H'
                    ,'EMSDIVISION_H'
                    ,'ENTRANCEPOINT_H'
                    ,'ESINETATOMICLINE_H'
                    ,'ESINETATOMICPOINT_H'
                    ,'EVENTROUTE_H'
                    ,'FEATURENAME_H'
                    ,'FIREBATTALION_H'
                    ,'FIRECOMPANY_H'
                    ,'FIREDIVISION_H'
                    ,'HEALTHAREA_H'
                    ,'HEALTHCENTERDISTRICT_H'
                    ,'HISTORICDISTRICT_H'
                    ,'HURRICANEEVACUATIONZONE_H'
                    ,'LASTWORD_H'
                    ,'LINKNYC_H'
                    ,'MEDIAN_H'
                    ,'MILEPOST_H'
                    ,'MUNICIPALCOURTDISTRICT_H'
                    ,'NAMEDINTERSECTION_H'
                    ,'NEIGHBORHOOD_H'
                    ,'NEIGHBORHOODPUMACODES_H'
                    ,'NODE_H'
                    ,'NONSTREETFEATURE_H'
                    ,'NYPDBOROUGHCOMMAND_H'
                    ,'NYPDPRECINCT_H'
                    ,'NYPDSECTOR_NEW_H'
                    ,'NYPDTOW_H'
                    ,'PARADEROUTE_H'
                    ,'PERMIT_H'
                    ,'PHYSICALRESTRICTION_H'
                    ,'QUARTERSECTIONALMAP_H'
                    ,'RAIL_H'
                    ,'RAILSTATION_H'
                    ,'RAILSTATIONSHAVEFEATURENAMES_H'
                    ,'REFERENCEMARKER_H'
                    ,'ROADBEDPOINTERLIST_H'
                    ,'SCHOOLDISTRICT_H'
                    ,'SECTIONALMAP_H'
                    ,'SEDAT_H'
                    ,'SEGMENT_LGC_H'
                    ,'SHORELINE_H'
                    ,'SNOWROUTE_H'
                    ,'SPECIALDISASTER_H'
                    ,'SPECIALINTERSECTIONS_H'
                    ,'SPECIALSEDAT_H'
                    ,'STATESENATEDISTRICT_H'
                    ,'STREETNAME_H'
                    ,'STREETSHAVEINTERSECTIONS_H'
                    ,'STREETTYPE_H'
                    ,'SUBWAY_H'
                    ,'SUBWAYSTATION_H'
                    ,'SUBWAYSTATIONSHAVEFEATURENA_H'
                    ,'TOLLBOOTH_H'
                    ,'TRAFFICCALMINGDEVICE_H'
                    ,'TRAFFICCAMERA_H'
                    ,'TRANSITBOOTH_H'
                    ,'TRANSITEMERGENCYEXIT_H'
                    ,'TRANSITENTRANCE_H'
                    ,'TRAVELRESTRICTION_H'
                    ,'TRUCKROUTE_H'
                    ,'TURNRESTRICTION_H'
                    ,'TURNRESTRICTIONLIMITS_H'
                    ,'UNIVERSALWORD_H'
                    ,'URBANRENEWALAREA_H'
                    ,'VIRTUALCENTERLINE_H'
                    ,'VIRTUALINTERSECTION_H'
                    ,'ZIPCODE_H'
                    )
order by b.table_name