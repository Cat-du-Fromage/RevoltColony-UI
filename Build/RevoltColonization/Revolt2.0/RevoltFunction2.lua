-- RevoltFunction2
-- Author: Florian
-- DateCreated: 2/19/2020 6:05:07 PM
--------------------------------------------------------------
include ("NewSaveUtils")
include ("RevoltUtils")
include ("TableSaverLoader")
--==============================================================================================
--GLOBALS
RESERVED_CITY_STATES = 10 -- number of city states reserved
gT = {}
ReserveCS = "ReservedCS"

--==============================================================================================
function ReserveCS()

	print ("------------------ ")
	print ("Initializing City-States... ")

	local numCS = NumCS()
	
	print ("  - Number of CS required by the player = " .. numCS)

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
	
	print ("  - Number of loaded CS in game = " .. #loadedCS)
	print ("  - Number of inactivated CS    = " .. #inactiveCS)

	local reservedCS = {}

	if RESERVED_CITY_STATES > #loadedCS then
		print ("  - WARNING : Loaded CS < RESERVED_CITY_STATES, reserving all available CS")
		for i = 1, #loadedCS do
			local playerID = loadedCS[i]
			RemoveCiv (playerID)
			reservedCS[playerID] = { Action = nil, Type = nil, Reference = nil}
		end
	elseif numCS + RESERVED_CITY_STATES > #loadedCS then
		print ("  - Not enough CS active for all request, keeping " .. #loadedCS - RESERVED_CITY_STATES .. " alive...")
		for i = #loadedCS - RESERVED_CITY_STATES, #loadedCS do
			local playerID = loadedCS[i]
			RemoveCiv (playerID)
			reservedCS[playerID] = { Action = nil, Type = nil, Reference = nil}
		end
	else
		print ("  - Keeping " .. numCS .. " alive..." )
		for i = numCS + 1, #loadedCS do
			local playerID = loadedCS[i]
			RemoveCiv (playerID)
			reservedCS[playerID] = { Action = nil, Type = nil, Reference = nil}
		end
	end
	TableSave( reservedCS, "ReservedCS" ) --changement par rapport à l'original
end
--=====================================================================================
--Retire La City-State pour réservation
--=====================================================================================
function RemoveCiv (playerID)
	local player = Players[playerID]
	-- kill all units
	for v in player:Units() do
		v:Kill()
	end
end
--=====================================================================================
--Number Of CS in the game
--=====================================================================================
function NumCS()
local numCS = 0
	local pPlayer = Players[Game.GetActivePlayer()]
	for i = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_PLAYERS - 1 do
		if Players[i]:IsMinorCiv() then
			numCS = numCS + 1
		end
	end
	return numCS
end
--=====================================================================================
--Libère les city-State non utilisée
--=====================================================================================
function FreeReservedCS()

	print ("------------------ ")
	print ("Removing uneeded reservation for CS...")

	local cultureMap = MapModData.AH.CultureMap
	local reservedCS = TableLoad ("ReservedCS")
	local civToRemove = {}
	local cultureToRemove = {}
	for id, data in pairs(reservedCS) do
		if data.Action then
			local player = Players[id]
			if not player:IsAlive() then
				Dprint ("  - Found dead rebels : " .. player:GetName(), bDebug)

				local cityStateType = GetCivTypeFromPlayer(id)

				local tagStr = string.gsub (cityStateType, "MINOR_CIV_", "")

				SetText ("RESERVED", "TXT_KEY_CITYSTATE_" .. tagStr)
				SetText ("RESERVED", "TXT_KEY_CITYSTATE_" .. tagStr .. "_ADJ")
				SetText ("Rebels Cities", "TXT_KEY_CIV5_" .. tagStr .. "_TEXT")

				RefreshText()

				reservedCS[id].Action = nil
				reservedCS[id].Type = nil
				reservedCS[id].Reference = nil
				local rebel = Players[id]
				for playerID = 0, GameDefines.MAX_PLAYERS do
					local player = Players[playerID]
					if player and (id ~= playerID) and not player:IsBarbarian() and player:IsEverAlive() then
						MakePermanentPeace(id, playerID)
						if not player:IsMinorCiv() then
							rebel:ChangeMinorCivFriendshipWithMajor(playerID, - rebel:GetMinorCivFriendshipWithMajor(playerID))
						end
					end
				end

				table.insert(civToRemove, cityStateType)
			end
		end
	end