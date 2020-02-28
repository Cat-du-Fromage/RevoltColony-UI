-- RebelsSpawn
-- Author: Florian
-- DateCreated: 2/26/2020 4:06:01 PM
--------------------------------------------------------------
include("PlotIterators.lua")
--===============================================================
--UNIT TYPE LAND
--===============================================================
--UnitType Melee
function MeleeUnitRebelsColony(playerID)
local player = playerID
	if player:HasTech(GameInfoTypes["TECH_COMBINED_ARMS"]) then
		meleeUnit = GameInfoTypes["UNIT_INFANTRY"]
	elseif player:HasTech(GameInfoTypes["TECH_REPLACEABLE_PARTS"]) then
		meleeUnit = GameInfoTypes["UNIT_GREAT_WAR_INFANTRY"]
	elseif player:HasTech(GameInfoTypes["TECH_RIFLING"]) then
		meleeUnit = GameInfoTypes["UNIT_RIFLEMAN"]
	elseif player:HasTech(GameInfoTypes["TECH_GUNPOWDER"]) then
		meleeUnit = GameInfoTypes["UNIT_SPANISH_TERCIO"]
	else
		meleeUnit = GameInfoTypes["UNIT_PIKEMAN"]
	end
	return meleeUnit
end
--UnitType Range
function RangeUnitRebelsColony(playerID)
local player = playerID
	if player:HasTech(GameInfoTypes["TECH_NUCLEAR_FISSION"]) then
		rangeUnit = GameInfoTypes["UNIT_BAZOOKA"]
	elseif player:HasTech(GameInfoTypes["TECH_BALLISTICS"]) then
		rangeUnit = GameInfoTypes["UNIT_MACHINE_GUN"]
	elseif player:HasTech(GameInfoTypes["TECH_DYNAMITE"]) then
		rangeUnit = GameInfoTypes["UNIT_GATLINGGUN"]
	elseif player:HasTech(GameInfoTypes["TECH_METALLURGY"]) then
		rangeUnit = GameInfoTypes["UNIT_MUSKETMAN"]
	elseif player:HasTech(GameInfoTypes["TECH_MACHINERY"]) then
		rangeUnit = GameInfoTypes["UNIT_CROSSBOWMAN"]
	else
		rangeUnit = GameInfoTypes["UNIT_COMPOSITE_BOWMAN"]
	end
	return rangeUnit
end
--UnitType Siege
function SiegeUnitRebelsColony(playerID)
local player = playerID
	if player:HasTech(GameInfoTypes["TECH_ADVANCED_BALLISTICS"]) then
		siegeUnit = GameInfoTypes["UNIT_ROCKET_ARTILLERY"]
	elseif player:HasTech(GameInfoTypes["TECH_BALLISTICS"]) then
		siegeUnit = GameInfoTypes["UNIT_ARTILLERY"]
	elseif player:HasTech(GameInfoTypes["TECH_RIFLING"]) then
		siegeUnit = GameInfoTypes["UNIT_FIELD_GUN"]
	elseif player:HasTech(GameInfoTypes["TECH_GUNPOWDER"]) then
		siegeUnit = GameInfoTypes["UNIT_CANNON"]
	else
		siegeUnit = GameInfoTypes["UNIT_TREBUCHET"]
	end
	return siegeUnit
end


--===============================================================
--UNIT TYPE SEA
--===============================================================
--UnitType Melee Naval
function MeleeNavalUnitRebelsColony(playerID)
local player = playerID
	if player:HasTech(GameInfoTypes["TECH_ADVANCED_BALLISTICS"]) then
		MeleeNaval = GameInfoTypes["UNIT_MISSILE_DESTROYER"]
	elseif player:HasTech(GameInfoTypes["TECH_ROCKETRY"]) then
		MeleeNaval = GameInfoTypes["UNIT_DESTROYER"]
	elseif player:HasTech(GameInfoTypes["TECH_COMBUSTION"]) then
		MeleeNaval = GameInfoTypes["UNIT_EARLY_DESTROYER"]
	elseif player:HasTech(GameInfoTypes["TECH_INDUSTRIALIZATION"]) then
		MeleeNaval = GameInfoTypes["UNIT_IRONCLAD"]
	elseif player:HasTech(GameInfoTypes["TECH_NAVIGATION"]) then
		MeleeNaval = GameInfoTypes["UNIT_PRIVATEER"]
	else
		MeleeNaval = GameInfoTypes["UNIT_CARAVEL"]
	end
	return MeleeNaval
end

--UnitType Range Naval
function RangeNavalUnitRebelsColony(playerID)
local player = playerID
	if player:HasTech(GameInfoTypes["TECH_LASERS"]) then
		RangeNaval = GameInfoTypes["UNIT_MISSILE_CRUISER"]
	elseif player:HasTech(GameInfoTypes["TECH_ELECTRONICS"]) then
		RangeNaval = GameInfoTypes["UNIT_BATTLESHIP"]
	elseif player:HasTech(GameInfoTypes["TECH_RADIO"]) then
		RangeNaval = GameInfoTypes["UNIT_DREADNOUGHT"]
	elseif player:HasTech(GameInfoTypes["TECH_DYNAMITE"]) then
		RangeNaval = GameInfoTypes["UNIT_CRUISER"]
	elseif player:HasTech(GameInfoTypes["TECH_NAVIGATION"]) then
		RangeNaval = GameInfoTypes["UNIT_FRIGATE"]
	else
		RangeNaval = GameInfoTypes["UNIT_FRIGATE"]
	end
	return RangeNaval
end

-----------------------------------------------------------------

function GetRandom(lower, upper)
    return (Game.Rand((upper + 1) - lower, "")) + lower
end

--=========================================================================================
--Function Spawn LAND UNIT
--=========================================================================================
--SPAWN AREA FOR MELEE
function AreaSpawnMeleeRebel(cityID, playerID, RebelLVL, NumUnit)
	local pBarbarian = Players[63]
	local pCity = cityID
	local iPlayer = playerID
	local rebelLVL = RebelLVL
	local meleeUnit = MeleeUnitRebelsColony(iPlayer)
	local iNumtoPlace = NumUnit
	local pPlot = pCity:Plot()
    local tPlots = {}
    for pLoopPlot in PlotAreaSpiralIterator(pPlot, 2, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_EXCLUDE) do
        table.insert(tPlots, pLoopPlot)
		if pLoopPlot:GetOwner() == iPlayer then
			table.insert(tPlots, pLoopPlot)
			table.insert(tPlots, pLoopPlot)
		end
    end

	local pTargetPlot = nil

	    for iVal = 1, iNumtoPlace do
		local bPlaced = false
		while (not(bPlaced)) and #tPlots > 0 do
			local iRandom = GetRandom(1, #tPlots)
			local pPlot = tPlots[iRandom]
			if (pPlot:GetNumUnits() == 0) and (pPlot:IsCity() == false) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_COAST"]) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_OCEAN"]) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_MOUNTAIN"]) and (pPlot:GetFeatureType() ~= GameInfoTypes["FEATURE_ICE"]) and (not(pPlot:IsLake())) and ((pPlot:GetOwner() == -1) or (pPlot:GetOwner() == iPlayer) and (not(pPlot:IsNaturalWonder())) ) then
			pPlotX = pPlot:GetX()
			pPlotY = pPlot:GetY()
			pmeleeUnit = pBarbarian:InitUnit(meleeUnit, pPlotX, pPlotY)
			pmeleeUnit:JumpToNearestValidPlot()
			pTargetPlot = pPlot
			bPlaced = true
			end
			table.remove(tPlots, iRandom)
		end
	end
	return pTargetPlot
end
--SPAWN AREA FOR RANGE
function AreaSpawnRangeRebel(cityID, playerID, RebelLVL, NumUnit)
	local pBarbarian = Players[63]
	local pCity = cityID
	local iPlayer = playerID
	local rebelLVL = RebelLVL
	local rangeUnit = RangeUnitRebelsColony(iPlayer)
	local iNumtoPlace = NumUnit
	local pPlot = pCity:Plot()
    local tPlots = {}
    for pLoopPlot in PlotAreaSpiralIterator(pPlot, 2, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_EXCLUDE) do
        table.insert(tPlots, pLoopPlot)
		if pLoopPlot:GetOwner() == iPlayer then
			table.insert(tPlots, pLoopPlot)
			table.insert(tPlots, pLoopPlot)
		end
    end

	local pTargetPlot = nil

	    for iVal = 1, iNumtoPlace do
		local bPlaced = false
		while (not(bPlaced)) and #tPlots > 0 do
			local iRandom = GetRandom(1, #tPlots)
			local pPlot = tPlots[iRandom]
			if (pPlot:GetNumUnits() == 0) and (pPlot:IsCity() == false) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_COAST"]) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_OCEAN"]) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_MOUNTAIN"]) and (pPlot:GetFeatureType() ~= GameInfoTypes["FEATURE_ICE"]) and (not(pPlot:IsLake())) and ((pPlot:GetOwner() == -1) or (pPlot:GetOwner() == iPlayer) and (not(pPlot:IsNaturalWonder())) ) then
			pPlotX = pPlot:GetX()
			pPlotY = pPlot:GetY()

			prangeUnit = pBarbarian:InitUnit(rangeUnit, pPlotX, pPlotY)
			prangeUnit:JumpToNearestValidPlot()
			pTargetPlot = pPlot
			bPlaced = true

			end
			table.remove(tPlots, iRandom)
		end
	end
	return pTargetPlot
end
--SPAWN AREA FOR SIEGE
function AreaSpawnSiegeRebel(cityID, playerID, RebelLVL, NumUnit)
	local pBarbarian = Players[63]
	local pCity = cityID
	local iPlayer = playerID
	local rebelLVL = RebelLVL
	local siegeUnit = SiegeUnitRebelsColony(iPlayer)
	local iNumtoPlace = NumUnit
	local pPlot = pCity:Plot()
    local tPlots = {}
    for pLoopPlot in PlotAreaSpiralIterator(pPlot, 2, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_EXCLUDE) do
        table.insert(tPlots, pLoopPlot)
		if pLoopPlot:GetOwner() == iPlayer then
			table.insert(tPlots, pLoopPlot)
			table.insert(tPlots, pLoopPlot)
		end
    end

	local pTargetPlot = nil

	    for iVal = 1, iNumtoPlace do
		local bPlaced = false
		while (not(bPlaced)) and #tPlots > 0 do
			local iRandom = GetRandom(1, #tPlots)
			local pPlot = tPlots[iRandom]
			if (pPlot:GetNumUnits() == 0) and (pPlot:IsCity() == false) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_COAST"]) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_OCEAN"]) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_MOUNTAIN"]) and (pPlot:GetFeatureType() ~= GameInfoTypes["FEATURE_ICE"]) and (not(pPlot:IsLake())) and ((pPlot:GetOwner() == -1) or (pPlot:GetOwner() == iPlayer) and (not(pPlot:IsNaturalWonder())) ) then
			pPlotX = pPlot:GetX()
			pPlotY = pPlot:GetY()
			psiegeUnit = pBarbarian:InitUnit(siegeUnit, pPlotX, pPlotY)
			psiegeUnit:JumpToNearestValidPlot()
			pTargetPlot = pPlot
			bPlaced = true
			end
			table.remove(tPlots, iRandom)
		end
	end
	return pTargetPlot
end

--=========================================================================================
--Function Spawn SEA UNIT
--=========================================================================================
--SPAWN AREA FOR MELEE NAVAL
function AreaSpawnNavalMeleeRebel(cityID, playerID, RebelLVL, NumUnit)
	local pBarbarian = Players[63]
	local pCity = cityID
	local iPlayer = playerID
	local rebelLVL = RebelLVL
	local navalMelee = MeleeNavalUnitRebelsColony(iPlayer)
	local iNumtoPlace = NumUnit
	local pPlot = pCity:Plot()
    local tPlots = {}
    for pLoopPlot in PlotAreaSpiralIterator(pPlot, 2, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_EXCLUDE) do
        table.insert(tPlots, pLoopPlot)
		if pLoopPlot:GetOwner() == iPlayer then
			table.insert(tPlots, pLoopPlot)
			table.insert(tPlots, pLoopPlot)
		end
    end

	local pTargetPlot = nil

	    for iVal = 1, iNumtoPlace do
		local bPlaced = false
		while (not(bPlaced)) and #tPlots > 0 do
			local iRandom = GetRandom(1, #tPlots)
			local pPlot = tPlots[iRandom]
			if (pPlot:GetNumUnits() == 0) and (pPlot:IsCity() == false) and (pPlot:GetTerrainType() == GameInfoTypes["TERRAIN_COAST"] or pPlot:GetTerrainType() == GameInfoTypes["TERRAIN_OCEAN"]) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_MOUNTAIN"]) and (pPlot:GetFeatureType() ~= GameInfoTypes["FEATURE_ICE"]) and (not(pPlot:IsLake())) and ((pPlot:GetOwner() == -1) or (pPlot:GetOwner() == iPlayer) and (not(pPlot:IsNaturalWonder())) ) then
			pPlotX = pPlot:GetX()
			pPlotY = pPlot:GetY()
				if rebelLVL > 1 then
				pnavalMelee = pBarbarian:InitUnit(navalMelee, pPlotX, pPlotY)
				pnavalMelee:JumpToNearestValidPlot()
				pTargetPlot = pPlot
				bPlaced = true
				end
			end
			table.remove(tPlots, iRandom)
		end
	end
	return pTargetPlot
end


--SPAWN AREA FOR RANGE NAVAL
function AreaSpawnNavalRangeRebel(cityID, playerID, RebelLVL, NumUnit)
	local pBarbarian = Players[63]
	local pCity = cityID
	local iPlayer = playerID
	local rebelLVL = RebelLVL
	local navalRange = RangeNavalUnitRebelsColony(iPlayer)
	local iNumtoPlace = NumUnit
	local pPlot = pCity:Plot()
    local tPlots = {}
    for pLoopPlot in PlotAreaSpiralIterator(pPlot, 2, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_EXCLUDE) do
        table.insert(tPlots, pLoopPlot)
		if pLoopPlot:GetOwner() == iPlayer then
			table.insert(tPlots, pLoopPlot)
			table.insert(tPlots, pLoopPlot)
		end
    end

	local pTargetPlot = nil

	    for iVal = 1, iNumtoPlace do
		local bPlaced = false
		while (not(bPlaced)) and #tPlots > 0 do
			local iRandom = GetRandom(1, #tPlots)
			local pPlot = tPlots[iRandom]
			if (pPlot:GetNumUnits() == 0) and (pPlot:IsCity() == false) and (pPlot:GetTerrainType() == GameInfoTypes["TERRAIN_COAST"] or pPlot:GetTerrainType() == GameInfoTypes["TERRAIN_OCEAN"]) and (pPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_MOUNTAIN"]) and (pPlot:GetFeatureType() ~= GameInfoTypes["FEATURE_ICE"]) and (not(pPlot:IsLake())) and ((pPlot:GetOwner() == -1) or (pPlot:GetOwner() == iPlayer) and (not(pPlot:IsNaturalWonder())) ) then
			pPlotX = pPlot:GetX()
			pPlotY = pPlot:GetY()
				if rebelLVL > 1 then
				pnavalRange = pBarbarian:InitUnit(navalRange, pPlotX, pPlotY)
				pnavalRange:JumpToNearestValidPlot()
				pTargetPlot = pPlot
				bPlaced = true
				end
			end
			table.remove(tPlots, iRandom)
		end
	end
	return pTargetPlot
end
--=========================================================================================
--Fonction Assez de terre?
--=========================================================================================
function NumEarth(pCity)
	local pPlot = pCity:Plot()
    local tPlots = {}
	local iPlayer = pCity:GetOwner()
    local iNumtoPlace = 1
    for pLoopPlot in PlotAreaSpiralIterator(pPlot, 3, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_EXCLUDE) do
        table.insert(tPlots, pLoopPlot)
		if pLoopPlot:GetOwner() == iPlayer then
			table.insert(tPlots, pLoopPlot)
			table.insert(tPlots, pLoopPlot)
		end
    end
	local numEarth = 0;
	for i, pLoopPlot in pairs(tPlots) do
		if ((pLoopPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_COAST"]) and (pLoopPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_OCEAN"]) and (pLoopPlot:GetTerrainType() ~= GameInfoTypes["TERRAIN_MOUNTAIN"])) then
		numEarth = numEarth + 1
		end
	end
	return numEarth
end

--Water 1 tile around the city
function NumWater(pCity)
	local pPlot = pCity:Plot()
    local tPlots = {}
	local iPlayer = pCity:GetOwner()
    local iNumtoPlace = 1
    for pLoopPlot in PlotAreaSpiralIterator(pPlot, 1, SECTOR_NORTH, DIRECTION_CLOCKWISE, DIRECTION_OUTWARDS, CENTRE_EXCLUDE) do
        table.insert(tPlots, pLoopPlot)
		if pLoopPlot:GetOwner() == iPlayer then
			table.insert(tPlots, pLoopPlot)
			table.insert(tPlots, pLoopPlot)
		end
    end

	local numWater = 0;

	for i, pLoopPlot in pairs(tPlots) do
		if (pLoopPlot:GetTerrainType() == GameInfoTypes["TERRAIN_COAST"] or pLoopPlot:GetTerrainType() == GameInfoTypes["TERRAIN_OCEAN"]) then
		numWater = numWater + 1
		end
	end
	return numWater
end

--=========================================================================================
--Function Main
--=========================================================================================

function MainSpawnRebels(playerID, cityID, RebelLVL)
local player = playerID
local city = cityID
local rebelLVL = RebelLVL
	--NAVAL UNIT
	if (NumWater(city) == 6) or ((city:IsCoastal() == true) and (NumEarth(city) <= 10)) then
		if rebelLVL == 1 then
		AreaSpawnNavalMeleeRebel(city, player, rebelLVL, 1)
		elseif rebelLVL == 2 then
		AreaSpawnNavalMeleeRebel(city, player, rebelLVL, 1)
		AreaSpawnNavalRangeRebel(city, player, rebelLVL, 1)
		elseif rebelLVL == 3 or rebelLVL == 4 then
		AreaSpawnNavalMeleeRebel(city, player, rebelLVL, 2)
		AreaSpawnNavalRangeRebel(city, player, rebelLVL, 1)
		elseif rebelLVL == 5 then
		AreaSpawnNavalMeleeRebel(city, player, rebelLVL, 2)
		AreaSpawnNavalRangeRebel(city, player, rebelLVL, 2)
		end

	else
	--LAND UNIT
		if rebelLVL == 1 then
		AreaSpawnMeleeRebel(city, player, rebelLVL, 1)
		AreaSpawnRangeRebel(city, player, rebelLVL, 1)
		elseif rebelLVL == 2 then
		AreaSpawnMeleeRebel(city, player, rebelLVL, 2)
		AreaSpawnRangeRebel(city, player, rebelLVL, 1)
		elseif rebelLVL == 3 or rebelLVL == 4 then
		AreaSpawnMeleeRebel(city, player, rebelLVL, 2)
		AreaSpawnRangeRebel(city, player, rebelLVL, 1)
		AreaSpawnSiegeRebel(city, player, rebelLVL, 1)
		elseif rebelLVL == 5 then
		AreaSpawnMeleeRebel(city, player, rebelLVL, 3)
		AreaSpawnSiegeRebel(city, player, rebelLVL, 2)
		end

	end


end
