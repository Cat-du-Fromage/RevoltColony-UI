-- LoyalityFunction
-- Author: Florian
-- DateCreated: 2/27/2020 9:09:13 PM
--------------------------------------------------------------
--==================================================================================================================
--COLONY WE LOVE THE KING DAY
--==================================================================================================================
function ColonyWLTKD(playerID, cityID)
local player = playerID
local city = cityID
local WLTKDBonus = 0
	if city:GetWeLoveTheKingDayCounter() > 0 then
	print("WLTKDBonus OK")
	WLTKDBonus = 10
	else
	WLTKDBonus = 0
	end
return WLTKDBonus
end
--==================================================================================================================
--EMPIRE GOLDEN AGE
--==================================================================================================================
function ColonyGoldenAge(playerID)
local player = playerID
local GABonus = 0
	if player:IsGoldenAge() == true then
	GABonus = 15
	print("GA OK")
	else
	GABonus = 0
	end
return GABonus
end
--==================================================================================================================
--COLONY TRADE ROUTE TO METROPOLE
--==================================================================================================================
function TradeRouteAny(playerID, cityID)
local player = playerID
local colony = cityID
local TradeAnyBonus = 0

local pColonyX = colony:GetX()
local pColonyY = colony:GetY()
local plot = Map.GetPlot(pColonyX, pColonyY)
local pColony = plot:GetPlotCity()
	for _,v in ipairs(player:GetTradeRoutes()) do
	print("TradeRouteAny ok 1")
		if v.ToCity == pColony then
		print("TradeRouteAny ok 2")
		local pFromCity = v.FromCity
		--ajouter: la ville ne doit pas être une colonie
		local pToCity = v.ToCity
		TradeAnyBonus = TradeAnyBonus + 1
		print("TradeRouteAny ok 3", TradeAnyBonus)
		end
	end
return TradeAnyBonus
end

--==================================================================================================================
--LOYALITY MAIN
--==================================================================================================================
function LoyalityBonus(cityID, playerID)
colony = cityID
player = playerID

--WLTKD
local WLTKDBonus = ColonyWLTKD(player, colony)
--GOLDEN AGE
local GABonus = ColonyGoldenAge(player)
--Trade Route from Any City
local TradeAnyBonus = ( TradeRouteAny(player, colony) )*5
print("TradeAnyBonus", TradeAnyBonus)

--TotalBonusLoyality
local LoyalityBonus = WLTKDBonus + GABonus + TradeAnyBonus

return LoyalityBonus
end