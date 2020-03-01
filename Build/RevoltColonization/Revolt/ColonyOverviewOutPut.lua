-- ColonyOverviewOutPut
-- Author: Florian
-- DateCreated: 2/29/2020 7:58:56 PM
--------------------------------------------------------------

function DoApplyColonyGeneralTaxe(playerID)
local DummyTaxe = GameInfoTypes.BUILDING_GENERAL_TAXE
local player = playerID
local capital = player:GetCapitalCity()
	if player:CountNumBuildings(DummyGeneralTaxeTimer) == 0 then
	capital:SetNumRealBuilding(DummyDissiConnection, 1)
	end
end

function CanSetGeneralTaxe(playerID)
local player = playerID
local DummyGeneralTaxeTimer = GameInfoTypes.BUILDING_GENERAL_TAXE_TIMER
	if player:CountNumBuildings(DummyGeneralTaxeTimer) ~= 0 then
	return false
	else
	return true
	end

end