-- RevoltFunction
-- Author: Florian
-- DateCreated: 2/20/2020 9:45:51 AM
--------------------------------------------------------------
include ("RouteConnections")
include("PlotIterators.lua")
include("RebelsSpawn.lua")
include("LoyalityFunction.lua")
include("DissidenceFunction.lua")
include("CSRebels.lua")
--------------------------------------------------------------------------------------------------
local SpawnTimer = 2
local SpawnReset = SpawnTimer + 2
--Timer for rebel spawn (10 turns) XXXXXXXXXXXXXXXXXXXXXXX CHANGER TIMER
function SpawnRebelConditions(playerID, cityID, RebelLVL)
local DummyTimer = GameInfoTypes.BUILDING_TIMER
local player = playerID
local city = cityID
local rebelLVL = RebelLVL
local CurrentTimer = city:GetNumBuilding(DummyTimer)
	if CurrentTimer == SpawnReset then -- remet le timer à 0 quand arrivé à max
		city:SetNumRealBuilding(DummyTimer, 0)
	else
		if rebelLVL >= 1 then
			city:SetNumRealBuilding(DummyTimer, CurrentTimer+1)
			print("TIMER ok", CurrentTimer)
		end
	print("TIMER ok", CurrentTimer)
	end
	return CurrentTimer
end

--Damage on garrison and colony
function DamageCity(playerID, cityID, RebelLVL)
local player = playerID
local city = cityID
local rebelLVL = RebelLVL
local damage = city:GetPopulation()
	if rebelLVL >= 1 then
		if city:GetGarrisonedUnit() ~= nil then
		garrisonunit = city:GetGarrisonedUnit()
			if garrisonunit:IsCombatUnit() == true then
			garrisonunit:ChangeDamage(damage)
			end
		end
	end

	if rebelLVL >= 2 then
		city:ChangeDamage(damage)
	end

end

function MainFunction(playerID) --XXXXXXXXXXXXXXXXXXXXXXX mettre condition tech + num building
local buildingGovernorsMansionID = GameInfoTypes["BUILDING_JFD_GOVERNORS_MANSION"]
local DummyTimer = GameInfoTypes.BUILDING_TIMER
local rebelLVL = 0
local player = Players[playerID]
local currentTimer = player:CountNumBuildings(DummyTimer)

if player:IsHuman() == true then
	if player:HasTech(GameInfoTypes["TECH_ASTRONOMY"] and player:CountNumBuildings(buildingGovernorsMansionID) > 0) then
		for city in player:Cities() do
				if city:IsColony() == true then
				local dissidenceConnectionMetropole = DissidenceConnectionMetropole(city, player)
						if ColonyDissidence(city, player) >= 50 --[[and ColonyDissidence(city, player) < 60 ]]then
							local rebelLVL = 1
							SpawnRebelConditions(player, city, rebelLVL)
							DamageCity(player, city, rebelLVL)
							if currentTimer == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1--[[ or city:IsResistance() == false ]]then 
							city:ChangeResistanceTurns(10)
							end
						elseif ColonyDissidence(city, player) >= 60 and ColonyDissidence(city, player) < 70 then
							local rebelLVL = 2
							SpawnRebelConditions(player, city, rebelLVL)
							DamageCity(playerID, cityID, RebelLVL)
							if currentTimer == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1 or city:IsResistance() == false then 
							city:ChangeResistanceTurns(10)
							end
						elseif ColonyDissidence(city, player) >= 70 and ColonyDissidence(city, player) < 80 then
							local rebelLVL = 3
							SpawnRebelConditions(player, city, rebelLVL)
							DamageCity(playerID, cityID, RebelLVL)
							if currentTimer == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1 or city:IsResistance() == false then 
							city:ChangeResistanceTurns(10)
							end
						elseif ColonyDissidence(city, player) >= 80 and ColonyDissidence(city, player) < 90 then
							local rebelLVL = 4
							SpawnRebelConditions(player, city, rebelLVL)
							DamageCity(playerID, cityID, RebelLVL)
							if currentTimer == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1 or city:IsResistance() == false then 
							city:ChangeResistanceTurns(10)
							end
						elseif ColonyDissidence(city, player) >= 90 then
							local rebelLVL = 5
							SpawnRebelConditions(player, city, rebelLVL)
							DamageCity(playerID, cityID, RebelLVL)
							if currentTimer == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1 or city:IsResistance() == false then 
							city:ChangeResistanceTurns(10)
							end
						end
				end
		end
	end
end
end
GameEvents.PlayerDoTurn.Add(MainFunction)