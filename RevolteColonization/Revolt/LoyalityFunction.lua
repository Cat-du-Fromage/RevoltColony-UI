-- LoyalityFunction
-- Author: Florian
-- DateCreated: 2/27/2020 9:09:13 PM
--------------------------------------------------------------
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