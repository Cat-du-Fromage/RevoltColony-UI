------------------------------	
-- Building_Promotion (NEW)
------------------------------

			INSERT INTO Building_FreeSpecUnits
			("BuildingType",					"UnitType",			"NumUnits") 
VALUES		('BUILDING_PALACE',	'UNIT_JFD_COLONIST',		'2');




--===========================================
 --Dummy Metropole
 --===========================================

INSERT INTO BuildingClasses
			(Type,						DefaultBuilding,	NoLimit)
VALUES		('BUILDINGCLASS_GOVERNORS_MANSION', 'BUILDING_GOVERNORS_MANSION', 1);

INSERT INTO Buildings
			(Type,				BuildingClass,									Description, GoldMaintenance, Cost, FaithCost, GreatWorkCount, NeverCapture, NukeImmune, ConquestProb, HurryCostModifier, IconAtlas,		PortraitIndex, IsDummy)
VALUES		('BUILDING_GOVERNORS_MANSION','BUILDINGCLASS_GOVERNORS_MANSION',	'Teste',	 0,					-1,		-1,			-1,				1,			1,			0,			-1,				'CIV_COLOR_ATLAS',		0,			1);





--===========================================
 --Dummy Metropole
 --===========================================
INSERT INTO BuildingClasses
			(Type,						DefaultBuilding,	NoLimit)
VALUES		('BUILDINGCLASS_SNOWBALL', 'BUILDING_SNOWBALL', 1);

INSERT INTO Buildings
			(Type,				BuildingClass,									Description, GoldMaintenance, Cost, FaithCost, GreatWorkCount, NeverCapture, NukeImmune, ConquestProb, HurryCostModifier, IconAtlas,		PortraitIndex, IsDummy)
VALUES		('BUILDING_SNOWBALL','BUILDINGCLASS_SNOWBALL',	'Teste',	 0,					-1,		-1,			-1,				1,			1,			0,			-1,				'CIV_COLOR_ATLAS',		0,			1);

--===========================================
 --Dummy Metropole
 --===========================================
INSERT INTO BuildingClasses
			(Type,						DefaultBuilding,	NoLimit)
VALUES		('BUILDINGCLASS_TIMER', 'BUILDING_TIMER', 1);

INSERT INTO Buildings
			(Type,				BuildingClass,									Description, GoldMaintenance, Cost, FaithCost, GreatWorkCount, NeverCapture, NukeImmune, ConquestProb, HurryCostModifier, IconAtlas,		PortraitIndex, IsDummy)
VALUES		('BUILDING_TIMER','BUILDINGCLASS_TIMER',	'Teste',	 0,					-1,		-1,			-1,				1,			1,			0,			-1,				'CIV_COLOR_ATLAS',		0,			1);

--===========================================
 --Dummy Colony Taxe
 --===========================================
INSERT INTO BuildingClasses
			(Type,						DefaultBuilding,	NoLimit)
VALUES		('BUILDINGCLASS_PERSO_TAXE', 'BUILDING_PERSO_TAXE', 1);

INSERT INTO Buildings
			(Type,				BuildingClass,									Description, GoldMaintenance, Cost, FaithCost, GreatWorkCount, NeverCapture, NukeImmune, ConquestProb, HurryCostModifier, IconAtlas,		PortraitIndex, IsDummy)
VALUES		('BUILDING_PERSO_TAXE','BUILDINGCLASS_PERSO_TAXE',	'Teste',	 0,					-1,		-1,			-1,				1,			1,			0,			-1,				'CIV_COLOR_ATLAS',		0,			1);

--===========================================
 --Dummy Colony General Taxe Timer
 --===========================================
INSERT INTO BuildingClasses
			(Type,						DefaultBuilding,	NoLimit)
VALUES		('BUILDINGCLASS_GENERAL_TAXE_TIMER', 'BUILDING_GENERAL_TAXE_TIMER', 1);

INSERT INTO Buildings
			(Type,				BuildingClass,									Description, GoldMaintenance, Cost, FaithCost, GreatWorkCount, NeverCapture, NukeImmune, ConquestProb, HurryCostModifier, IconAtlas,		PortraitIndex, IsDummy)
VALUES		('BUILDING_GENERAL_TAXE_TIMER','BUILDINGCLASS_GENERAL_TAXE_TIMER',	'Teste',	 0,					-1,		-1,			-1,				1,			1,			0,			-1,				'CIV_COLOR_ATLAS',		0,			1);

--===========================================
 --Dummy Colony General Taxe
 --===========================================
INSERT INTO BuildingClasses
			(Type,						DefaultBuilding,	NoLimit)
VALUES		('BUILDINGCLASS_GENERAL_TAXE', 'BUILDING_GENERAL_TAXE', 1);

INSERT INTO Buildings
			(Type,				BuildingClass,									Description, GoldMaintenance, Cost, FaithCost, GreatWorkCount, NeverCapture, NukeImmune, ConquestProb, HurryCostModifier, IconAtlas,		PortraitIndex, IsDummy)
VALUES		('BUILDING_GENERAL_TAXE','BUILDINGCLASS_GENERAL_TAXE',	'Teste',	 0,					-1,		-1,			-1,				1,			1,			0,			-1,				'CIV_COLOR_ATLAS',		0,			1);
