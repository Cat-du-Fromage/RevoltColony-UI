-- DissidenceFunction
-- Author: Florian
-- DateCreated: 2/28/2020 1:55:18 PM
--------------------------------------------------------------
--===============================================================
--Globals
--===============================================================
-- Route types
AIR		= 1
LAND	= 2
SEA		= 3
ROAD	= 4
RAIL	= 5


local DummyDissiConnection = GameInfoTypes.BUILDING_GOVERNORS_MANSION
local DummyDissiSnowball = GameInfoTypes.BUILDING_SNOWBALL

--===============================================================
--Calculs dissidence
--===============================================================

--==================================================================================================================
--Empire Unhappiness
--==================================================================================================================
function DissidenceEmpire(playerID)
local player = playerID
local dissidenceEmpire = 0
	if player:IsEmpireSuperUnhappy() == true then
	dissidenceEmpire = dissidenceEmpire + 40
	print("unhappy", dissidenceEmpire)
	elseif player:IsEmpireVeryUnhappy() == true then
	dissidenceEmpire = dissidenceEmpire + 30
	print("Veryunhappy", dissidenceEmpire)
	elseif player:IsEmpireUnhappy() == true then
	dissidenceEmpire = dissidenceEmpire + 20
	print("Superunhappy", dissidenceEmpire)
	end
	return dissidenceEmpire
end

--==================================================================================================================
--Base unhapiness City
--==================================================================================================================
function DissidenceBase(cityID, playerID)
	local future = GameInfo.Eras["ERA_FUTURE"].ID
	local postmodern = GameInfo.Eras["ERA_POSTMODERN"].ID
	local modern = GameInfo.Eras["ERA_MODERN"].ID
	local industrial = GameInfo.Eras["ERA_INDUSTRIAL"].ID
	local renaissance = GameInfo.Eras["ERA_RENAISSANCE"].ID

	local city = cityID
	local player = playerID
	local dissidenceBase = 0
		if player:GetCurrentEra() == renaissance then
		 dissidenceBase = city:getUnhappinessAggregated()
		 --print("renaissance", dissidenceBase)
		elseif player:GetCurrentEra() == industrial or player:GetCurrentEra() == modern then
		 dissidenceBase = (city:getUnhappinessAggregated())*2
		 --print("industrial", dissidenceBase)
		elseif player:GetCurrentEra() == postmodern or player:GetCurrentEra() == future then
		 dissidenceBase = (city:getUnhappinessAggregated())*3
		end

return dissidenceBase
end

--------------------------------------------------------------------------------------------------
--==================================================================================================================
--PathBlocked
--==================================================================================================================
function PathBlocked(pPlot, pPlayer)
	if ( pPlot == nil or pPlayer == nil) then
		return true
	end

	local ownerID = pPlot:GetOwner()
	local playerID = pPlayer:GetID()

	if ( ownerID == playerID or ownerID == -1 ) then
		return false
	end

	local pOwner = Players [ ownerID ]

	if ( pPlayer:GetTeam() == pOwner:GetTeam() or pOwner:IsAllies(playerID) or pOwner:IsFriends(playerID) ) then
		return false
	end

	--local team1 = Teams [ pPlayer:GetTeam() ]
	local plotTeam = Teams [ pOwner:GetTeam() ]
	if plotTeam:IsAllowsOpenBordersToTeam( pPlayer:GetTeam() ) then
		return false
	end

	return true -- return true if the path is blocked...
end
--get nearest city
function GetNearestCity(pPlot, pPlayer)
	local iShortestDistance = 99999
	local pNearestCity = nil

	local iColonyX, iColonyY = pPlot:GetX(), pPlot:GetY()

	for pCity in pPlayer:Cities() do
		if pCity:IsColony() == false and pCity:IsPuppet() == false then
			local iDist = Map.PlotDistance(pCity:GetX(), pCity:GetY(), iColonyX, iColonyY)
			if (iDist < iShortestDistance) then
				iShortestDistance = iDist
				pNearestCity = pCity
			end
		end
	end
	return pNearestCity
end


--==================================================================================================================
--Connection to Metropole XXXXXXXXXXXXXXXXXXXXXXX CHANGER DISTANCE LAND
--==================================================================================================================
function DissidenceConnectionMetropole(cityID, playerID)

print("start colony connection")

local maxDistanceLand = 2
local maxDistanceRoad = 9
local maxDistanceRail = 12
local maxDistanceSea = 10

local player = playerID
local colony = cityID

--print("retour de la colony", colony, player, icolony)
local pColonyX = colony:GetX()
local pColonyY = colony:GetY()
local plot = Map.GetPlot(pColonyX, pColonyY)
local pColony = plot:GetPlotCity()
local metropoleConnection = 0
local dissidenceConnection = colony:GetNumBuilding(DummyDissiConnection)
			local metropole = GetNearestCity(pColony, player)
			--print("retour de la metropole", metropole)
			local landDist, seaDist, roadDist, railDist = -1, -1, -1, -1 -- initialize distance for each city

			if isCityConnected(player, colony, metropole, "Land", true, nil, PathBlocked) then
				-- distance by land plot
				landDist = getRouteLength()-1
				print ("    - Land distance : ", landDist)
				-- distance by road
				if isCityConnected(player, colony, metropole, "Road", true, nil, PathBlocked) then
					roadDist = getRouteLength()-1
					print ("    - Road distance : ", roadDist)
				end
				-- distance by rail
				if isCityConnected(player, colony, metropole, "Railroad", true, nil, PathBlocked) then
					railDist = getRouteLength()-1
					print ("    - Rail distance : " , railDist)
				end
			else
				-- distance by sea
				local seaStr = "Ocean" -- to do : add a check for ability to cross ocean
				if isCityConnected(player, colony, metropole, seaStr, true, nil, PathBlocked) then
					seaDist = getRouteLength()-1
					print ("    - Maritime distance : ", seaDist)
				end
			end
		--Calcul si la colony n'est pas trop loin de la métropole

			if ((landDist <= maxDistanceLand) and (landDist ~= -1) ) then
				metropoleConnection = metropoleConnection + 1
				--ROAD
			elseif ((roadDist <= maxDistanceRoad) and (roadDist ~= -1) ) then
				metropoleConnection = metropoleConnection + 1
				--RAIL
			elseif ((railDist <= maxDistanceRail) and (railDist ~= -1) ) then
				metropoleConnection = metropoleConnection + 1
				--Connection maritime
			elseif colony:IsCoastal() == true then
				if colony:GetNumBuilding(GameInfo.Buildings.BUILDING_HARBOR.ID) > 0 then
					if ((seaDist <= (maxDistanceSea + 2)) and (seaDist ~= -1) ) then
					metropoleConnection = metropoleConnection + 1
					end
				else
					if ((seaDist <= maxDistanceSea) and (seaDist ~= -1))  then
					metropoleConnection = metropoleConnection + 1
					end
				end
			end
			if metropoleConnection ~= 0 then
			print("la colony est connectee", dissidenceConnection)
				if dissidenceConnection > 0 then
				colony:SetNumRealBuilding(DummyDissiConnection, dissidenceConnection-1)
				end
			elseif metropoleConnection == 0 then
			print("la colony est pas connectee", dissidenceConnection)
				colony:SetNumRealBuilding(DummyDissiConnection, dissidenceConnection+2)
			end
	--print("Connection test fin", dissidenceConnection)
	return dissidenceConnection
end

function DissidenceConnectionNumBuilding(cityID, playerID)
local player = playerID
local colony = cityID
local dissidenceConnectionNumBuilding = colony:GetNumBuilding(DummyDissiConnection)
return dissidenceConnectionNumBuilding
end
--------------------------------------------------------------------------------------------------
--==================================================================================================================
--WarWeariness
--==================================================================================================================
function DissidenceWarWeariness(playerID)
local dissidenceWW = 0
local player = playerID
local dissidenceWW = player:GetWarWeariness()
print("DissidenceWarWeariness ok", dissidenceWW)
return dissidenceWW
end

--------------------------------------------------------------------------------------------------
--==================================================================================================================
--Negativ GPT
--==================================================================================================================
function DissidenceGPT(playerID)
--local player = Players[Game.GetActivePlayer()]
local player = playerID
local dissidenceGPT = 0
	if player:CalculateGoldRate() < 0 then
	local playerGPT = player:CalculateGoldRate()
	dissidenceGPT = dissidenceGPT - playerGPT
	print("DissidenceGPT ok", dissidenceGPT)
	end
	--print("DissidenceGPT ok", dissidenceGPT)
	return dissidenceGPT
end
