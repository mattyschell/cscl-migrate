SET LINESIZE 200
SET PAGESIZE 100
DEFINE outfile = '&1'
SPOOL &outfile
call sde.nyc_archive_utils.register_archiving('ACCESSPOINTSTOENTRANCEPOINTS' ,'ACCESSPOINTSTOENTRANCEPOINTS_H' ,1399742968);
call sde.nyc_archive_utils.register_archiving('ACCESSPOINTTOADDRESSPOINT' ,'ACCESSPOINTTOADDRESSPOINT4_H' ,1399742720);
call sde.nyc_archive_utils.register_archiving('ACCESSPOINT' ,'ACCESSPOINT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('ADDRESSPOINTLGCS' ,'ADDRESSPOINTLGCS_H' ,1272900564);
call sde.nyc_archive_utils.register_archiving('ADDRESSPOINT' ,'ADDRESSPOINT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('ADJACENTBOROUGHBOUNDARY' ,'ADJACENTBOROUGHBOUNDARY_H' ,1748009919);
call sde.nyc_archive_utils.register_archiving('ADMINBOUNDARIES' ,'ADMINBOUNDARIES_H' ,1272900568);
call sde.nyc_archive_utils.register_archiving('ALARMBOXAREA' ,'ALARMBOXAREA_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('ALARMBOX' ,'ALARMBOX_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('ALTSEGMENTDATA' ,'ALTSEGMENTDATA_H' ,1272900572);
call sde.nyc_archive_utils.register_archiving('ASSEMBLYDISTRICT' ,'ASSEMBLYDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('ATOMICPOLYGON' ,'ATOMICPOLYGON_H' ,1273244647);
call sde.nyc_archive_utils.register_archiving('BLOCKFACE' ,'BLOCKFACE_H' ,1272903360);
call sde.nyc_archive_utils.register_archiving('BOROUGH' ,'BOROUGH_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('BUSINESSIMPROVEMENTDISTRICT' ,'BUSINESSIMPROVEMENTDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('CADSOURCEADDRESS' ,'CADSOURCEADDRESS_H' ,1272903363);
call sde.nyc_archive_utils.register_archiving('CELLULARCALLBOX' ,'CELLULARCALLBOX_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('CENSUSBLOCK2000' ,'CENSUSBLOCK2000_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('CENSUSBLOCK2010' ,'CENSUSBLOCK2010_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('CENSUSTRACT1990' ,'CENSUSTRACT1990_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('CENSUSTRACT2000' ,'CENSUSTRACT2000_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('CENSUSTRACT2010' ,'CENSUSTRACT2010_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('CENTERLINEHISTORY' ,'CENTERLINEHISTORY_H' ,1272903371);
call sde.nyc_archive_utils.register_archiving('CENTERLINE' ,'CENTERLINE_H1' ,1273244647);
call sde.nyc_archive_utils.register_archiving('CITYCOUNCILDISTRICT' ,'CITYCOUNCILDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('CITYLIMIT' ,'CITYLIMIT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('COMMONPLACEBULKLOADSTAGING' ,'COMMONPLACEBULKLOADSTAGING_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('COMMONPLACESHAVEACCESSPOINTS' ,'COMMONPLACESHAVEACCESSPOINTS_H' ,1399743188);
call sde.nyc_archive_utils.register_archiving('COMMONPLACESHAVEADDRESSPOINTS' ,'COMMONPLACESHAVEADDRESSPOIN_H' ,1399743467);
call sde.nyc_archive_utils.register_archiving('COMMONPLACESHAVEFEATURENAMES' ,'COMMONPLACESHAVEFEATURENAMES_H' ,1399743650);
call sde.nyc_archive_utils.register_archiving('COMMONPLACE' ,'COMMONPLACE_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('COMMUNITYDISTRICT' ,'COMMUNITYDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('COMPLEXACCESSPOINT' ,'COMPLEXACCESSPOINT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('COMPLEXINTERSECTION' ,'COMPLEXINTERSECTION_H' ,1272905180);
call sde.nyc_archive_utils.register_archiving('COMPLEX' ,'COMPLEX_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('CONGRESSIONALDISTRICT' ,'CONGRESSIONALDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('DELETEDSTREETCODES' ,'DELETEDSTREETCODES_H' ,1272903442);
call sde.nyc_archive_utils.register_archiving('ELECTIONDISTRICT' ,'ELECTIONDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('ELEVATION' ,'ELEVATION_H' ,1272903450);
call sde.nyc_archive_utils.register_archiving('EMSATOM' ,'EMSATOM_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('EMSBATTALION' ,'EMSBATTALION_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('EMSDISPATCHAREA' ,'EMSDISPATCHAREA_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('EMSDIVISION' ,'EMSDIVISION_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('ENTRANCEPOINT' ,'ENTRANCEPOINT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('ESINETATOMICLINE' ,'ESINETATOMICLINE_H' ,1691158617);
call sde.nyc_archive_utils.register_archiving('ESINETATOMICPOINT' ,'ESINETATOMICPOINT_H' ,1691158635);
call sde.nyc_archive_utils.register_archiving('EVENTROUTE' ,'EVENTROUTE_H' ,1272903455);
call sde.nyc_archive_utils.register_archiving('FEATURENAME' ,'FEATURENAME_H' ,1272903459);
call sde.nyc_archive_utils.register_archiving('FIREBATTALION' ,'FIREBATTALION_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('FIRECOMPANY' ,'FIRECOMPANY_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('FIREDIVISION' ,'FIREDIVISION_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('HEALTHAREA' ,'HEALTHAREA_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('HEALTHCENTERDISTRICT' ,'HEALTHCENTERDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('HISTORICDISTRICT' ,'HISTORICDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('HURRICANEEVACUATIONZONE' ,'HURRICANEEVACUATIONZONE_H' ,1409932765);
call sde.nyc_archive_utils.register_archiving('LASTWORD' ,'LASTWORD_H' ,1272903476);
call sde.nyc_archive_utils.register_archiving('LINKNYC' ,'LINKNYC_H' ,1460042711);
call sde.nyc_archive_utils.register_archiving('MEDIAN' ,'MEDIAN_H' ,1273244647);
call sde.nyc_archive_utils.register_archiving('MILEPOST' ,'MILEPOST_H' ,1273244647);
call sde.nyc_archive_utils.register_archiving('MUNICIPALCOURTDISTRICT' ,'MUNICIPALCOURTDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('NAMEDINTERSECTION' ,'NAMEDINTERSECTION_H' ,1272903482);
call sde.nyc_archive_utils.register_archiving('NEIGHBORHOODPUMACODES' ,'NEIGHBORHOODPUMACODES_H' ,1272903485);
call sde.nyc_archive_utils.register_archiving('NEIGHBORHOOD' ,'NEIGHBORHOOD_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('NODE' ,'NODE_H' ,1273244647);
call sde.nyc_archive_utils.register_archiving('NONSTREETFEATURE' ,'NONSTREETFEATURE_H' ,1273244647);
call sde.nyc_archive_utils.register_archiving('NYPDPATROLBOROUGH' ,'NYPDBOROUGHCOMMAND_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('NYPDPRECINCT' ,'NYPDPRECINCT_H' ,1291155153);
call sde.nyc_archive_utils.register_archiving('NYPDSECTOR' ,'NYPDSECTOR_NEW_H' ,1285258199);
call sde.nyc_archive_utils.register_archiving('NYPDTOW' ,'NYPDTOW_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('PARADEROUTE' ,'PARADEROUTE_H' ,1272903489);
call sde.nyc_archive_utils.register_archiving('PERMIT' ,'PERMIT_H' ,1272903495);
call sde.nyc_archive_utils.register_archiving('PHYSICALRESTRICTION' ,'PHYSICALRESTRICTION_H' ,1272903498);
call sde.nyc_archive_utils.register_archiving('QUARTERSECTIONALMAP' ,'QUARTERSECTIONALMAP_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('RAILSTATIONSHAVEFEATURENAMES' ,'RAILSTATIONSHAVEFEATURENAMES_H' ,1399743860);
call sde.nyc_archive_utils.register_archiving('RAILSTATION' ,'RAILSTATION_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('RAIL' ,'RAIL_H' ,1273244647);
call sde.nyc_archive_utils.register_archiving('REFERENCEMARKER' ,'REFERENCEMARKER_H' ,1273244647);
call sde.nyc_archive_utils.register_archiving('ROADBEDPOINTERLIST' ,'ROADBEDPOINTERLIST_H' ,1272903504);
call sde.nyc_archive_utils.register_archiving('SCHOOLDISTRICT' ,'SCHOOLDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('SECTIONALMAP' ,'SECTIONALMAP_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('SEDAT' ,'SEDAT_H' ,1272903509);
call sde.nyc_archive_utils.register_archiving('SEGMENT_LGC' ,'SEGMENT_LGC_H' ,1272903513);
call sde.nyc_archive_utils.register_archiving('SHORELINE' ,'SHORELINE_H' ,1273244647);
call sde.nyc_archive_utils.register_archiving('SNOWROUTE' ,'SNOWROUTE_H' ,1272903560);
call sde.nyc_archive_utils.register_archiving('SPECIALDISASTER' ,'SPECIALDISASTER_H' ,1272903563);
call sde.nyc_archive_utils.register_archiving('SPECIALINTERSECTIONS' ,'SPECIALINTERSECTIONS_H' ,1272903566);
call sde.nyc_archive_utils.register_archiving('SPECIALSEDAT' ,'SPECIALSEDAT_H' ,1272903571);
call sde.nyc_archive_utils.register_archiving('STATESENATEDISTRICT' ,'STATESENATEDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('STREETNAME' ,'STREETNAME_H' ,1272903576);
call sde.nyc_archive_utils.register_archiving('STREETSHAVEINTERSECTIONS' ,'STREETSHAVEINTERSECTIONS_H' ,1272903609);
call sde.nyc_archive_utils.register_archiving('STREETTYPE' ,'STREETTYPE_H' ,1272903711);
call sde.nyc_archive_utils.register_archiving('SUBWAYSTATIONSHAVEFEATURENAMES' ,'SUBWAYSTATIONSHAVEFEATURENA_H' ,1399744306);
call sde.nyc_archive_utils.register_archiving('SUBWAYSTATION' ,'SUBWAYSTATION_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('SUBWAY' ,'SUBWAY_H' ,1273244647);
call sde.nyc_archive_utils.register_archiving('TOLLBOOTH' ,'TOLLBOOTH_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('TRAFFICCALMINGDEVICE' ,'TRAFFICCALMINGDEVICE_H' ,1272903720);
call sde.nyc_archive_utils.register_archiving('TRAFFICCAMERA' ,'TRAFFICCAMERA_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('TRANSITBOOTH' ,'TRANSITBOOTH_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('TRANSITEMERGENCYEXIT' ,'TRANSITEMERGENCYEXIT_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('TRANSITENTRANCE' ,'TRANSITENTRANCE_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('TRAVELRESTRICTION' ,'TRAVELRESTRICTION_H' ,1272903773);
call sde.nyc_archive_utils.register_archiving('TRUCKROUTE' ,'TRUCKROUTE_H' ,1272903780);
call sde.nyc_archive_utils.register_archiving('TURNRESTRICTIONLIMITS' ,'TURNRESTRICTIONLIMITS_H' ,1272903789);
call sde.nyc_archive_utils.register_archiving('TURNRESTRICTION' ,'TURNRESTRICTION_H' ,1272903785);
call sde.nyc_archive_utils.register_archiving('UNIVERSALWORD' ,'UNIVERSALWORD_H' ,1272903792);
call sde.nyc_archive_utils.register_archiving('URBANRENEWALAREA' ,'URBANRENEWALAREA_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('VIRTUALCENTERLINE' ,'VIRTUALCENTERLINE_H' ,1273245334);
call sde.nyc_archive_utils.register_archiving('VIRTUALINTERSECTION' ,'VIRTUALINTERSECTION_H' ,1272903796);
call sde.nyc_archive_utils.register_archiving('ZIPCODE' ,'ZIPCODE_H' ,1273245334);
SPOOL OFF
EXIT