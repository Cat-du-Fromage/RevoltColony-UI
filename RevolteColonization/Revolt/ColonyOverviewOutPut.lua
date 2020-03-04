-- ColonyOverviewOutPut
-- Author: Florian
-- DateCreated: 2/29/2020 7:58:56 PM
--------------------------------------------------------------
include("NewSaveUtils.lua")
include( "SaveUtils.lua" ); MY_MOD_NAME = "RevoltColonization";
--save( iValue, "GeneralTaxeValue", iTaxRate )

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
	save( player, "TaxeTimer", 3 )
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
		 capital:SetNumRealBuilding(DummyGeneralTaxeTimer, 0)
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
--local CurrentTimer = GetPersistentProperty("TaxeTimer")
--if GetPersistentProperty("TaxeTimer") ~= nil then
--newTimer = GetPersistentProperty("TaxeTimer") - 1
if (load(player, "TaxeTimer")) ~= nil then
newTimer = (load(player, "TaxeTimer") ) - 1
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

GameEvents.PlayerDoTurn.Add(TimerFade)
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