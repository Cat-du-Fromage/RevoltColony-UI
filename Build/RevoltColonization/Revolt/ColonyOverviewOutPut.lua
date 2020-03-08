-- ColonyOverviewOutPut
-- Author: Florian
-- DateCreated: 2/29/2020 7:58:56 PM
--------------------------------------------------------------
include("NewSaveUtils.lua")
WARN_NOT_SHARED = false; include( "SaveUtils" ); MY_MOD_NAME = "RevoltColonization";
--save( iValue, "GeneralTaxeValue", iTaxRate )
--GLOBALS
local DummyGeneralTaxe10 = GameInfoTypes.BUILDING_GENERAL_TAXE_10
local DummyGeneralTaxe20 = GameInfoTypes.BUILDING_GENERAL_TAXE_20
local DummyGeneralTaxe30 = GameInfoTypes.BUILDING_GENERAL_TAXE_30
local DummyGeneralTaxe40 = GameInfoTypes.BUILDING_GENERAL_TAXE_40
local DummyGeneralTaxe50 = GameInfoTypes.BUILDING_GENERAL_TAXE_50

--[[
--=========================================================================================================
--Set the Timer
--=========================================================================================================
function DoApplyColonyGeneralTaxeTIMER(playerID)
local DummyTaxe = GameInfoTypes.BUILDING_GENERAL_TAXE
local DummyGeneralTaxeTimer = GameInfoTypes.BUILDING_GENERAL_TAXE_TIMER
local player = Players[playerID]
--print( "DoApplyColonyGeneralTaxe PLAYER ", player )
local capital = player:GetCapitalCity()
--print( "DoApplyColonyGeneralTaxe ", capital )
	if player:CountNumBuildings(DummyGeneralTaxeTimer) == 0 then
	capital:SetNumRealBuilding(DummyGeneralTaxeTimer, 1)
	--SetPersistentProperty("TaxeTimer", 3)
	save( player, "TaxeTimer", 30 )
	end
end

--=========================================================================================================
--Colonies Income
--=========================================================================================================
function ColoniesIncome(playerID)
local player = playerID
--local player = Players[playerID]
--local CurrentTaxeValue = GetPersistentProperty("TaxeValue")
local coloniesIncome = 0
	for city in player:Cities() do
		if city:IsColony() == true then
		local cityYieldGold = city:GetYieldRateTimes100( YieldTypes.YIELD_GOLD ) / 100
		coloniesIncome = coloniesIncome + cityYieldGold
		end
	end
	return coloniesIncome
end

--=========================================================================================================
--Colonies Income
--=========================================================================================================
function DoApplyColonyGeneralTaxe(playerID)
--local player = playerID
local player = Players[playerID]
local capital = player:GetCapitalCity()
local DummyGeneralTaxeValue = GameInfoTypes.BUILDING_GENERAL_TAXE_VALUE
local DummyClassGeneralTaxeValue = GameInfoTypes.BUILDINGCLASS_GENERAL_TAXE_VALUE

--local CurrentTaxeValue = GetPersistentProperty("TaxeValue")
local CurrentTaxeValue = load(player, "GeneralTaxeValue")
local coloniesIncome = ColoniesIncome(player)

	if CurrentTaxeValue == 0 or CurrentTaxeValue == nil then
		 if player:CountNumBuildings(DummyGeneralTaxeValue) ~= 0 then
		 capital:SetNumRealBuilding(DummyGeneralTaxeValue, 0)
		 print( "On a plus de taxe ", coloniesIncome )
		 end
	else
	DoApplyColonyGeneralTaxeTIMER(playerID)
	capital:SetNumRealBuilding(DummyGeneralTaxeValue, 1)
	capital:SetBuildingYieldChange(DummyClassGeneralTaxeValue, YieldTypes.YIELD_GOLD, (CurrentTaxeValue/100)*coloniesIncome)
	print( "on a des taxes ", coloniesIncome )
	end
end
--=========================================================================================================
--Verify Colonies Income still up to date
--=========================================================================================================
function UpdateTaxe(playerID)
--local player = playerID
local player = Players[playerID]
local capital = player:GetCapitalCity()

local coloniesIncome = ColoniesIncome(player)
--local CurrentTaxeValue = GetPersistentProperty("TaxeValue")
local CurrentTaxeValue = load(player, "GeneralTaxeValue")
local DummyGeneralTaxeValue = GameInfoTypes.BUILDING_GENERAL_TAXE_VALUE
local DummyClassGeneralTaxeValue = GameInfoTypes.BUILDINGCLASS_GENERAL_TAXE_VALUE

if CurrentTaxeValue == nil or player:CountNumBuildings(DummyGeneralTaxeValue) == 0 then return end
	if capital:GetBuildingYieldChange(DummyClassGeneralTaxeValue, YieldTypes.YIELD_GOLD) ~= CurrentTaxeValue*coloniesIncome then
	capital:SetBuildingYieldChange(DummyClassGeneralTaxeValue, YieldTypes.YIELD_GOLD, (CurrentTaxeValue/100)*coloniesIncome)
	print( "la colonie a plus de fric ", coloniesIncome )
	end

end
GameEvents.PlayerDoTurn.Add(UpdateTaxe)
--=========================================================================================================
--Can we set taxe?
--=========================================================================================================

function CanSetGeneralTaxe(playerID)
local player = playerID
local DummyGeneralTaxeTimer = GameInfoTypes.BUILDING_GENERAL_TAXE_TIMER
	if player:CountNumBuildings(DummyGeneralTaxeTimer) ~= 0 then
	return false
	else
	return true
	end
end

function TimerFade(playerID)
local player = Players[playerID]
local capital = player:GetCapitalCity()
local CurrentTimer = load(player, "TaxeTimer")
if (load(player, "TaxeTimer")) ~= nil then
newTimer = CurrentTimer - 1
end
local DummyGeneralTaxeTimer = GameInfoTypes.BUILDING_GENERAL_TAXE_TIMER
	if player:CountNumBuildings(DummyGeneralTaxeTimer) ~= 0 then
		if CurrentTimer ~= 0 then
		--SetPersistentProperty("TaxeTimer", newTimer)
		print( "TimerFade ", CurrentTimer )
		save( player, "TaxeTimer", newTimer)
		elseif CurrentTimer == 0 then
		capital:SetNumRealBuilding(DummyGeneralTaxeTimer, 0)
		print( "TimerFade FIN")
		end
	end
end

--GameEvents.PlayerDoTurn.Add(TimerFade)
--=========================================================================================================
--Turn colony into CS
--=========================================================================================================
function ColonyLiberation(cityID)
local buildingGovernorsMansionID = GameInfoTypes["BUILDING_JFD_GOVERNORS_MANSION"]
local city = cityID
print( "COLONYLIBERATION ", cityID )
local player = Players[Game.GetActivePlayer()];
local eCity = player:GetCityByID(city)
local pColonyX = eCity:GetX()
local pColonyY = eCity:GetY()
local plot = Map.GetPlot(pColonyX, pColonyY)
local pCity = plot:GetPlotCity()
--local pBarbarian = Players[63]
--eCity:SetColony(false)
--eCity:SetPuppet(false)
--eCity:SetNumRealBuilding(buildingGovernorsMansionID, 0)
Game.DoSpawnFreeCity(pCity)
--pBarbarian:AcquireCity(city, false, true)
end
]]
--=======================================================================================================================================================================================
--NEW TAXE SYSTEM
--=======================================================================================================================================================================================
--=========================================================================================================
--Set the Timer
--=========================================================================================================

function GeneralTaxeTIMER(playerID, iTaxeValue)
local DummyTaxe = GameInfoTypes.BUILDING_GENERAL_TAXE
local DummyGeneralTaxeTimer = GameInfoTypes.BUILDING_GENERAL_TAXE_TIMER
local player = Players[playerID]
local capital = player:GetCapitalCity()
print("Taxe Value", iTaxeValue)
print("Taxe Value playerID", playerID)
print("Taxe Value player", player)
	if iTaxeValue ~= 0 and iTaxeValue ~= nil then
	capital:SetNumRealBuilding(DummyGeneralTaxeTimer, 4)
	GeneralTaxeDummy(playerID, iTaxeValue)
	TaxeOutput(playerID, iTaxeValue)
	elseif iTaxeValue == 0 then
	GeneralTaxeDummy(playerID, iTaxeValue)
	TaxeOutput(playerID, iTaxeValue)
	end
end
--=========================================================================================================
--TIMER FADE
--=========================================================================================================
function TimerGeneralTaxeFade(playerID)
local DummyGeneralTaxeTimer = GameInfoTypes.BUILDING_GENERAL_TAXE_TIMER
local player = Players[playerID]
local capital = player:GetCapitalCity()
local CurrentTimer = player:CountNumBuildings(DummyGeneralTaxeTimer)
--Timer - 1
local newTimer = CurrentTimer - 1

	if player:CountNumBuildings(DummyGeneralTaxeTimer) ~= 0 then
		if CurrentTimer ~= 0 and CurrentTimer > 0 then
		capital:SetNumRealBuilding(DummyGeneralTaxeTimer, newTimer)
		print( "TimerFade ", CurrentTimer )
		elseif CurrentTimer == 0 then
		capital:SetNumRealBuilding(DummyGeneralTaxeTimer, 0)
		print( "TimerFade FIN")
		end
	end
end

--=========================================================================================================
--Can we set taxe?
--=========================================================================================================
function CanSetGeneralTaxe(playerID)
local player = playerID
local DummyGeneralTaxeTimer = GameInfoTypes.BUILDING_GENERAL_TAXE_TIMER
	if player:CountNumBuildings(DummyGeneralTaxeTimer) > 0 then
	return false
	else
	return true
	end
end

--=========================================================================================================
--Set Building Taxe
--=========================================================================================================
function GeneralTaxeDummy(playerID, iTaxeValue)
local player = Players[playerID]
local capital = player:GetCapitalCity()

	if iTaxeValue == 0 then
	capital:SetNumRealBuilding(DummyGeneralTaxe10, 0) 
	capital:SetNumRealBuilding(DummyGeneralTaxe20, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe30, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe40, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe50, 0)
	end

	if iTaxeValue == 10 then
	capital:SetNumRealBuilding(DummyGeneralTaxe10, 1)

	capital:SetNumRealBuilding(DummyGeneralTaxe20, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe30, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe40, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe50, 0)
	print("je met 10")
	elseif iTaxeValue == 20 then
	capital:SetNumRealBuilding(DummyGeneralTaxe20, 1)
	capital:SetNumRealBuilding(DummyGeneralTaxe10, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe30, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe40, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe50, 0)
	print("je met 20")
	elseif iTaxeValue == 30 then
	capital:SetNumRealBuilding(DummyGeneralTaxe30, 1)
	capital:SetNumRealBuilding(DummyGeneralTaxe10, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe20, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe40, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe50, 0)
	print("je met 30")
	elseif iTaxeValue == 40 then
	capital:SetNumRealBuilding(DummyGeneralTaxe40, 1)
	capital:SetNumRealBuilding(DummyGeneralTaxe10, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe20, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe30, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe50, 0)
	print("je met 40")
	elseif iTaxeValue == 50 then
	capital:SetNumRealBuilding(DummyGeneralTaxe50, 1)
	capital:SetNumRealBuilding(DummyGeneralTaxe10, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe20, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe30, 0)
	capital:SetNumRealBuilding(DummyGeneralTaxe40, 0)
	print("je met 50")
	end

end
--=========================================================================================================
--Taxe Dummy Value
--=========================================================================================================

function GeneralTaxeDummyValue(playerID)
print("GeneralTaxeDummyValue playerID", playerID)
local player = Players[playerID]
print("GeneralTaxeDummyValue player", player)
local iPlayer = Players[Game.GetActivePlayer()]
print("GeneralTaxeDummyValue iPlayer", iPlayer)
local iGeneralTaxe = 0

	if iPlayer:CountNumBuildings(DummyGeneralTaxe50) == 1 then
	iGeneralTaxe = 50
	elseif iPlayer:CountNumBuildings(DummyGeneralTaxe40) == 1 then
	iGeneralTaxe = 40
	elseif iPlayer:CountNumBuildings(DummyGeneralTaxe30) == 1 then
	iGeneralTaxe = 30
	elseif iPlayer:CountNumBuildings(DummyGeneralTaxe20) == 1 then
	iGeneralTaxe = 20
	elseif iPlayer:CountNumBuildings(DummyGeneralTaxe10) == 1 then
	iGeneralTaxe = 10
	else
	iGeneralTaxe = 0
	end
	return iGeneralTaxe
end

--=========================================================================================================
--Colonies Income CALCULATION
--=========================================================================================================

function TaxeOutput(playerID, iTaxeValue)
local DummyGeneralTaxeValue = GameInfoTypes.BUILDING_GENERAL_TAXE_VALUE
local DummyClassGeneralTaxeValue = GameInfoTypes.BUILDINGCLASS_GENERAL_TAXE_VALUE

local player = Players[playerID]
local capital = player:GetCapitalCity()
local iColoniesNetIncome = ColoniesGPTConversion(playerID)

	if iTaxeValue == 0 and iTaxeValue == nil then
		 if player:CountNumBuildings(DummyGeneralTaxeValue) ~= 0 then
		 capital:SetNumRealBuilding(DummyGeneralTaxeValue, 0)
		 capital:SetBuildingYieldChange(DummyClassGeneralTaxeValue, YieldTypes.YIELD_GOLD, 0)
		 print( "On a plus de taxe ", coloniesIncome )
		 end
	else
	capital:SetNumRealBuilding(DummyGeneralTaxeValue, 1)
	capital:SetBuildingYieldChange(DummyClassGeneralTaxeValue, YieldTypes.YIELD_GOLD, (iTaxeValue/100)*iColoniesNetIncome)
	print( "on a des taxes ", (iTaxeValue/100)*iColoniesNetIncome )
	end

end



-----------------------------------------------------------------------------------------------------------
function ColoniesGPT(playerID)
local player = Players[playerID]
local iPlayer = Players[Game.GetActivePlayer()]
print("ColoniesGPT playerID", playerID)
print("ColoniesGPT player", player)
print("ColoniesGPT iPlayer", iPlayer)
local coloniesIncome = 0
	for city in iPlayer:Cities() do
		if city:IsColony() == true then
		local cityYieldGold = city:GetYieldRateTimes100( YieldTypes.YIELD_GOLD ) / 100
		coloniesIncome = coloniesIncome + cityYieldGold
		end
	end
	return coloniesIncome
end

function ColoniesGPTConversion(playerID)
local player = Players[playerID]
local iPlayer = Players[Game.GetActivePlayer()]
local iBrutColoniesIncome = ColoniesGPT(playerID)
local iNetColoniesIncome = 0
local iTaxeValue = GeneralTaxeDummyValue(playerID)

local BaseModifier = 0.2
local imperialismModifier = 0.5
local imperialismPolicy = GameInfoTypes.POLICY_MARITIME_INFRASTRUCTURE

	if iPlayer:HasPolicy(imperialismPolicy) then
	iNetColoniesIncome = iBrutColoniesIncome/imperialismModifier
	print("iNetColoniesIncome", iNetColoniesIncome)
	else
	iNetColoniesIncome = iBrutColoniesIncome/BaseModifier
	print("iNetColoniesIncome", iNetColoniesIncome)
	end
	return iNetColoniesIncome
end

--=========================================================================================================
--Verify Colonies Income still up to date
--=========================================================================================================
function UpdateTaxe(playerID)
local DummyGeneralTaxeValue = GameInfoTypes.BUILDING_GENERAL_TAXE_VALUE
local DummyClassGeneralTaxeValue = GameInfoTypes.BUILDINGCLASS_GENERAL_TAXE_VALUE

local player = Players[playerID]
local capital = player:GetCapitalCity()

local netColoniesIncome = ColoniesGPTConversion(player)
local CurrentTaxeValue = (GeneralTaxeDummyValue(player))/100

if CurrentTaxeValue == nil or player:CountNumBuildings(DummyGeneralTaxeValue) == 0 then return end
	if capital:GetBuildingYieldChange(DummyClassGeneralTaxeValue, YieldTypes.YIELD_GOLD) ~= CurrentTaxeValue*netColoniesIncome then
	capital:SetBuildingYieldChange(DummyClassGeneralTaxeValue, YieldTypes.YIELD_GOLD, CurrentTaxeValue*netColoniesIncome)
	print( "la colonie a plus de fric ", (CurrentTaxeValue)*netColoniesIncome )
	end

end
GameEvents.PlayerDoTurn.Add(UpdateTaxe)