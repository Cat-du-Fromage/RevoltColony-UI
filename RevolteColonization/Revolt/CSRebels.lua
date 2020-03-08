-- CSRebels
-- Author: Florian
-- DateCreated: 3/8/2020 3:16:03 PM
--------------------------------------------------------------
WARN_NOT_SHARED = false; include( "SaveUtils" ); MY_MOD_NAME = "RevoltColonization";
include("ColonyUtils.lua")
include("ShareData.lua")
local EuropeArtStyle = "ARTSTYLE_EUROPEAN"
local AsianArtStyle = "ARTSTYLE_ASIAN"
local GrecArtStyle = "ARTSTYLE_GRECO_ROMAN"
local AmericanArtStyle = "ARTSTYLE_SOUTH_AMERICA"
local AfricanArtStyle = "ARTSTYLE_MIDDLE_EAST"

local RESERVED_CITY_STATES = 10
local DEFAULT_SAVE_KEY = "1,1"

--THE FUCK IS THAT?!!!!!!
local ColonyModID = "d5e6aa4e-a6b9-4c28-ba62-81458bbb4c51"
local ColonyModVersion = Modding.GetLatestInstalledModVersion(ColonyModID)
modUserData = Modding.OpenUserData(ColonyModID, ColonyModVersion)

function CultureType(playerID)
local player = Players[playerID]
local cultureType = EuropeArtStyle
local playerArtStyle = GameInfo.Civilizations[playerCiv].ArtStyleType
cultureType = playerArtStyle
return cultureType
end
--==================================================================================================================
--RESERVE CITY-STATE
--==================================================================================================================
function ReserveCS()
	local iPlayer = Players[Game.GetActivePlayer()]
	--local numCS = modUserData.GetValue("NumMinorCivs")
	local numCS = 24

	local loadedCS = {}
	local inactiveCS = {}
	for playerID = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1 do
		local player = Players[playerID]
		local minorCivID = player:GetMinorCivType()
		-- Does this civ exist ?
		if minorCivID ~= -1 then
			table.insert(loadedCS, playerID)
			if player:GetNumUnits() == 0 then
				table.insert(inactiveCS, playerID)
			end
		end
	end
	
	print ("  - Number of loaded CS in game = ", #loadedCS)
	print ("  - Number of inactivated CS    = ",  #inactiveCS)

	local reservedCS = {}

	if RESERVED_CITY_STATES > #loadedCS then
		print ("  - WARNING : Loaded CS < RESERVED_CITY_STATES, reserving all available CS")
		for i = 1, #loadedCS do
			local playerID = loadedCS[i]
			RemoveCiv (playerID)
			reservedCS[playerID] = { Action = nil, Type = nil, Reference = nil}
		end
	elseif numCS + RESERVED_CITY_STATES > #loadedCS then
		print("NOT ENOUGH CS")
		for i = #loadedCS - RESERVED_CITY_STATES, #loadedCS do
			local playerID = loadedCS[i]
			RemoveCiv (playerID)
			reservedCS[playerID] = { Action = nil, Type = nil, Reference = nil}
		end
	else
		print ("  - Keeping ", numCS, "alive" )
		for i = numCS + 1, #loadedCS do
			local playerID = loadedCS[i]
			RemoveCiv (playerID)
			reservedCS[playerID] = { Action = nil, Type = nil, Reference = nil}
		end
	end
	save(iPlayer, "ReservedCS", reservedCS)
end
-- called once on first turn
function OnEnterGame ()
share_SaveUtils()
ReserveCS()
end
Events.LoadScreenClose.Add( OnEnterGame )

--------------------------------------------------------------
-- Civilizations functions 
--------------------------------------------------------------

function RemoveCiv (playerID)
	local player = Players[playerID]
	-- kill all units
	for v in player:Units() do
		v:Kill()
	end
end
--==================================================================================================================
--ASSIGN CS TO PLAYER
--==================================================================================================================
function AssignRebelSlot(freeSlots, playerID, rebelCultureType)
	print ("              - Preparing new slot for ", rebelCultureType)

	local reservedCS = load("ReservedCS")
	local rebelID = GetRebelIDForArtStyle(freeSlots, playerID, rebelCultureType)	
			
	reservedCS[rebelID].Action = "REVOLT"
	reservedCS[rebelID].Type = rebelCultureType
	reservedCS[rebelID].Reference = playerID

	SetRebelsText(rebelID, reservedCS)
	RefreshText()

	-- Set very bad relation with everyone
	local rebel = Players[rebelID]
	for player_num = 0, GameDefines.MAX_MAJOR_CIVS-1 do
		local player = Players[player_num]
		if ( player:IsEverAlive() ) then
			rebel:ChangeMinorCivFriendshipWithMajor(player_num, - rebel:GetMinorCivFriendshipWithMajor(player_num) + INITIAL_REBELS_RELATION)
		end
	end

	DeclarePermanentWar(rebelID, playerID)

	save( "ReservedCS", reservedCS )

	return rebelID
end
----------------------------------------
--assign CS according to the art style
-----------------------------------------
function GetRebelIDForArtStyle(freeSlots, playerID, rebelCultureType)
	
	local rebelID = freeSlots[1] -- take the first free slot

	-- Find art style of rebel culture group
	local rebelCiv = GetCivIDFromPlayerID (rebelID)
	local playerCiv = GetCivIDFromPlayerID (playerID)

	local playerArtStyle = "ARTSTYLE_EUROPEAN" -- default	
	if Players[playerID]:IsMinorCiv() then
		playerArtStyle = GameInfo.MinorCivilizations[playerCiv].ArtStyleType
	else
		playerArtStyle = GameInfo.Civilizations[playerCiv].ArtStyleType
	end
	print ("              - master civ ArtStyle : " , playerArtStyle)

	local rebelArtStyle = playerArtStyle -- Separatist will use player style
	if GameInfo.MinorCivilizations[rebelCultureType] then
		rebelArtStyle = GameInfo.MinorCivilizations[rebelCultureType].ArtStyleType
	elseif GameInfo.Civilizations[rebelCultureType] then
		rebelArtStyle = GameInfo.Civilizations[rebelCultureType].ArtStyleType
	end
	print ("              - rebel culture ArtStyle : ", rebelArtStyle)

	print ("              - First loop civ ArtStyle : " , GameInfo.MinorCivilizations[rebelCiv].ArtStyleType)

	-- Now try to find a corresponding artstyle in the available CS if the first one didn't match...
	if rebelArtStyle ~= GameInfo.MinorCivilizations[rebelCiv].ArtStyleType then
		print ("              - try to find corresponding ArtStyle : " , rebelArtStyle)
		for i, id in pairs(freeSlots) do 
			local civID = GetCivIDFromPlayerID (id)
			if GameInfo.MinorCivilizations[civID] then
				if rebelArtStyle == GameInfo.MinorCivilizations[civID].ArtStyleType then
					rebelID = id
				end
			end
		end
	end
	return rebelID
end

function GetFreeSlotsAndRebelID(reservedCS, playerID, cultureType)
	local rebelID = nil
	local freeSlots = {}
	for id, data in pairs(reservedCS) do -- debug "id"
		if not data.Action then
			table.insert(freeSlots, id)
		elseif (data.Type == cultureType) and (data.Reference == playerID) then
			print ("              - Slot already open, use it...")
			rebelID = id
		end
	end
	return freeSlots, rebelID
end