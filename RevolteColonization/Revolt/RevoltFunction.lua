-- RevoltFunction
-- Author: Florian
-- DateCreated: 2/20/2020 9:45:51 AM
--------------------------------------------------------------
include ("RouteConnections")
include("PlotIterators.lua")
include("RebelsSpawn.lua")
include("LoyalityFunction.lua")
include("DissidenceFunction.lua")

--------------------------------------------------------------------------------------------------

--Timer for rebel spawn (10 turns) XXXXXXXXXXXXXXXXXXXXXXX CHANGER TIMER
function SpawnRebelConditions(playerID, cityID, RebelLVL)
local DummyTimer = GameInfoTypes.BUILDING_TIMER
local player = playerID
local city = cityID
local rebelLVL = RebelLVL
local CurrentTimer = city:GetNumBuilding(DummyTimer)
	if CurrentTimer == 4 then -- remet le timer à 0 quand arrivé à max
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
--[[
-- unrest calculation for a colony
function ColonyDissidence(cityID, playerID)
local city = cityID
local player = playerID
local Dissidence = 0
--print("retour ColonyDissidence", city)

			local dissidenceWW = DissidenceWarWeariness(player)
			local dissidenceGPT = DissidenceGPT(player)
			--local dissidenceConnectionMetropole = DissidenceConnectionMetropole(city, player)
			local dissidenceConnectionMetropoleBuild = DissidenceConnectionNumBuilding(city, player)
			local dissidenceBaseUnHappiness = DissidenceBase(cityID, playerID)
			local dissidenceEmpire = DissidenceEmpire(player)
			local WLTKDBonus = ColonyWLTKD(player, city)
			local GABonus = ColonyGoldenAge(player)
			--
			if (Dissidence + dissidenceWW + dissidenceGPT + dissidenceConnectionMetropoleBuild + dissidenceBaseUnHappiness + dissidenceEmpire) >= 50 then
			Dissidence = (Dissidence + dissidenceWW + dissidenceGPT + dissidenceConnectionMetropoleBuild + dissidenceBaseUnHappiness + dissidenceEmpire) - (WLTKDBonus + GABonus)
			print("Dissidence ok", Dissidence)
			else
			Dissidence = (Dissidence + dissidenceWW + dissidenceGPT + dissidenceConnectionMetropoleBuild + dissidenceBaseUnHappiness + dissidenceEmpire) - (WLTKDBonus + GABonus)
			print("Dissidence ok", Dissidence)
			end
	return Dissidence
end

]]
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
local rebelLVL = 0
local player = Players[playerID]
--local garrisonunit = city:GetGarrisonedUnit()

local SpawnTimer = 3
if player:IsHuman() == true then
	--if player:HasTech(GameInfoTypes["TECH_ASTRONOMY"] and player:CountNumBuildings(buildingGovernorsMansionID) > 0) then
		for city in player:Cities() do
				if city:IsColony() == true then
				local dissidenceConnectionMetropole = DissidenceConnectionMetropole(city, player)
						if ColonyDissidence(city, player) >= 50 --[[and ColonyDissidence(city, player) < 60 ]]then
							local rebelLVL = 1
							DamageCity(player, city, rebelLVL)
							if SpawnRebelConditions(player, city, rebelLVL) == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1--[[ or city:IsResistance() == false ]]then 
							city:ChangeResistanceTurns(10)
							end
						elseif ColonyDissidence(city, player) >= 60 and ColonyDissidence(city, player) < 70 then
							local rebelLVL = 2
							DamageCity(playerID, cityID, RebelLVL)
							if SpawnRebelConditions(player, city, rebelLVL) == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1 or city:IsResistance() == false then 
							city:ChangeResistanceTurns(10)
							end
						elseif ColonyDissidence(city, player) >= 70 and ColonyDissidence(city, player) < 80 then
							local rebelLVL = 3
							DamageCity(playerID, cityID, RebelLVL)
							if SpawnRebelConditions(player, city, rebelLVL) == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1 or city:IsResistance() == false then 
							city:ChangeResistanceTurns(10)
							end
						elseif ColonyDissidence(city, player) >= 80 and ColonyDissidence(city, player) < 90 then
							local rebelLVL = 4
							DamageCity(playerID, cityID, RebelLVL)
							if SpawnRebelConditions(player, city, rebelLVL) == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1 or city:IsResistance() == false then 
							city:ChangeResistanceTurns(10)
							end
						elseif ColonyDissidence(city, player) >= 90 then
							local rebelLVL = 5
							DamageCity(playerID, cityID, RebelLVL)
							if SpawnRebelConditions(player, city, rebelLVL) == SpawnTimer then -- après 3 tours... surprise
							MainSpawnRebels(player, city, rebelLVL)
							end

							if city:GetResistanceTurns() == 1 or city:IsResistance() == false then 
							city:ChangeResistanceTurns(10)
							end
						end
				end
		end
	--end
	print(playerID, cityID, "it works colonyDissidence")
end
end
GameEvents.PlayerDoTurn.Add(MainFunction)