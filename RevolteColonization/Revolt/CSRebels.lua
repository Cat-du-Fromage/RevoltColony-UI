-- CSRebels
-- Author: Florian
-- DateCreated: 3/8/2020 3:16:03 PM
--------------------------------------------------------------
WARN_NOT_SHARED = false; include( "SaveUtils" ); MY_MOD_NAME = "RevoltColonization";
include("ShareData.lua")
local EuropeArtStyle = "ARTSTYLE_EUROPEAN"
local AsianArtStyle = "ARTSTYLE_ASIAN"
local GrecArtStyle = "ARTSTYLE_GRECO_ROMAN"
local AmericanArtStyle = "ARTSTYLE_SOUTH_AMERICA"
local AfricanArtStyle = "ARTSTYLE_MIDDLE_EAST"

local RESERVED_CITY_STATES = 10
local DEFAULT_SAVE_KEY = "1,1"
local INITIAL_REBELS_RELATION = -120
--[[
--THE FUCK IS THAT?!!!!!!
local ColonyModID = "d5e6aa4e-a6b9-4c28-ba62-81458bbb4c51"
local ColonyModVersion = Modding.GetLatestInstalledModVersion(ColonyModID)
modUserData = Modding.OpenUserData(ColonyModID, ColonyModVersion)
]]
--==================================================================================================================
--REVOLT OUTPUT MAIN
--==================================================================================================================
function CultureType(playerID)
local player = playerID:GetID()
local civPlayerID = GameInfo.Civilizations[playerID:GetCivilizationType()].ID

local playerArtStyle = GameInfo.Civilizations[civPlayerID].ArtStyleType
print("CultureType playerArtStyle", playerArtStyle)
	if playerArtStyle == nil then
	playerArtStyle = EuropeArtStyle -- default	
	end
cultureType = playerArtStyle
return cultureType
end

--==================================================================================================================
--RESERVE CITY-STATE
--==================================================================================================================
function ReserveCS()
	--local hPlayer = Players[Game.GetActivePlayer()]
	local iPlayer = Players[0]
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
--GET FREE SLOT TO ASSIGN TO REBELS
--==================================================================================================================
function GetFreeSlotsAndRebelID(reservedCS, playerID, cultureType)
	local iPlayer = playerID:GetID()
	local rebelID = nil
	local freeSlots = {}
	for id, data in pairs(reservedCS) do -- debug "id"
		if not data.Action then
			table.insert(freeSlots, id)
		elseif (data.Type == cultureType) and (data.Reference == playerID) then
			print ("              - Slot already open, use it...")
			rebelID = id
			DeclarePermanentWar(rebelID, iPlayer)
		end
	end
	return freeSlots, rebelID
end
--==================================================================================================================
--ASSIGN CS TO PLAYER
--==================================================================================================================
function AssignRebelSlot(freeSlots, playerID, rebelCultureType)
	print ("              - Preparing new slot for ", rebelCultureType)
	local iPlayer = Players[0]
	local iPlayerID = playerID:GetID()
	local reservedCS = load(iPlayer, "ReservedCS")
	local rebelID = GetRebelIDForArtStyle(freeSlots, playerID, rebelCultureType)	

	reservedCS[rebelID].Action = "REVOLT"
	reservedCS[rebelID].Type = rebelCultureType
	reservedCS[rebelID].Reference = playerID

	--SetRebelsText(rebelID, reservedCS)
	--RefreshText()

	-- Set very bad relation with everyone
	local rebel = Players[rebelID]
	print("AssignRebelSlot rebel", rebel)
	for player_num = 0, GameDefines.MAX_MAJOR_CIVS-1 do
		local player = Players[player_num]
		if ( player:IsEverAlive() ) then
			rebel:ChangeMinorCivFriendshipWithMajor(player_num, - rebel:GetMinorCivFriendshipWithMajor(player_num) + INITIAL_REBELS_RELATION)
		end
	end

	DeclarePermanentWar(rebelID, iPlayerID)

	save(iPlayer, "ReservedCS", reservedCS )

	return rebelID
end
----------------------------------------
--assign CS according to the art style
-----------------------------------------

function GetRebelIDForArtStyle(freeSlots, playerID, rebelCultureType)
	
	local rebelID = freeSlots[1] -- take the first free slot

	-- Find art style of rebel culture group
	local pRebel = Players[rebelID]

	local iPlayer = playerID:GetID() --playerID


	local playerArtStyle = playerID:GetArtStyleType()
		print(" GetRebelIDForArtStyle playerArtStyle", playerArtStyle)

	print ("              - master civ ArtStyle : " , playerArtStyle)

	local rebelArtStyle = playerArtStyle -- Separatist will use player style
	print ("              - rebel culture ArtStyle : ", rebelArtStyle)
	local pMinor = pRebel:GetMinorCivType()
	local civID = GameInfo.MinorCivilizations[pMinor].ID

	-- Now try to find a corresponding artstyle in the available CS if the first one didn't match...
	if rebelArtStyle ~= GameInfo.MinorCivilizations[civID].ArtStyleType then

		for i, id in pairs(freeSlots) do
			local freeslotID = Players[id]

			local freeslotMinorID = Players[id]:GetMinorCivType()

			local minorTypeID = freeslotID:GetMinorCivType()

			local pMinorType = Players[minorTypeID]

			local minorArtType = GameInfo.MinorCivilizations[minorTypeID].ArtStyleType
			local minorArtID = GameInfo.ArtStyleTypes[minorArtType].ID

			if GameInfo.MinorCivilizations[freeslotMinorID] then
			newRebelArtStyle = minorArtID

				if playerArtStyle == newRebelArtStyle then
				print ("civID type correspond au player", rebelArtStyle)
				rebelID = id
				print ("civID type correspond au player rebelID", rebelID)
				end
			end
		end
	end
	pRebel = Players[rebelID]
	print ("civID type correspond au player pRebel", pRebel)
	pRebel:SetPersonality(2)
	print ("civID type correspond au player SetPersonality", pRebel:GetPersonality())
	return rebelID
end
--==================================================================================================================
--UTILITIES
--==================================================================================================================
--[[
-- Functions to hide Minor civ War Button
function UpdateCityStateScreen( popupInfo )

	if( popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO ) then
		return
	end
	
	print ("-------------------------------------")
	print ("Check Peace button for Minor civ...")
	
    local minorPlayerID = popupInfo.Data1
    --local minorTeamID = Players[minorPlayerID]:GetTeam()	
	local playerID = Game.GetActivePlayer()
	local team = Teams [Players[playerID]:GetTeam()]
	
	local strToolTip = nil
	local strText = nil
	local strStatusText = nil
	local strStatusTooltip = nil
	local background = nil

	if IsRebellingAgainst(minorPlayerID, playerID) then
		print ("War forced beetwen player and ")
		bForcedWar = true
		strToolTip = "You can't make peace with rebels."
		strText = "[ICON_RESISTANCE] Viva la Revolucion ! [ICON_RESISTANCE]"
		
		strStatusText = "[COLOR_NEGATIVE_TEXT]Rebelling against your rule ![ENDCOLOR]"

		strStatusTooltip = ""

		ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/PeaceButton"):SetDisabled(true)

	elseif IsRebelling(minorPlayerID) then
		print ("Entering Rebel City-State Screen of ")

		strText = "[ICON_RESISTANCE] Viva la Revolucion ! [ICON_RESISTANCE]"

		local master = Players[GetMaster(minorPlayerID)]
		strStatusText = "[COLOR_PLAYER_YELLOW_TEXT]Rebelling against ".. tostring(master:GetName()) .."[ENDCOLOR]"

		strStatusTooltip = ""

		-- hide everything except Peace and war...
		if ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/UnitGiftButton") then ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/UnitGiftButton"):SetHide(true); end -- Vanilla 
		if ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/GiveButton") then ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/GiveButton"):SetHide(true); end -- Expansion 
		ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/PledgeButton"):SetHide(true)
		if ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/RevokePledgeButton") then ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/RevokePledgeButton"):SetHide(true); end -- Expansion 
		if ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/TakeButton") then ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/TakeButton"):SetHide(true); end -- Expansion 
		if ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/BuyoutButton") then ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/BuyoutButton"):SetHide(true); end -- Expansion 
		ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/NoUnitSpawningButton"):SetHide(true)

	else
		ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/PeaceButton"):SetDisabled(false)
		ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/PeaceButton"):SetToolTipString( "" )
	end
	
	-- Update Screen
	if strToolTip then ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/PeaceButton"):SetToolTipString( strToolTip ); end		
	if strText then ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/DescriptionLabel"):SetText( strText ); end	
	if strStatusText then ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/StatusInfo"):SetText( strStatusText ); end
	if strStatusTooltip then ContextPtr:LookUpControl("/InGame/CityStateDiploPopup/StatusInfo"):SetToolTipString( strStatusTooltip ); end

end

Events.SerialEventGameMessagePopup.Add(UpdateCityStateScreen)
]]
function DeclarePermanentWar(iPlayer1, iPlayer2)
	local player1 = Players[ iPlayer1 ]
	local player2 = Players[ iPlayer2 ]
	local team1 = Teams[ player1:GetTeam() ]
	local team2 = Teams[ player2:GetTeam() ]
	team1:DeclareWar( player2:GetTeam() )
	team1:SetPermanentWarPeace( player2:GetTeam(), true)
	team2:SetPermanentWarPeace( player1:GetTeam(), true)
end

function GetMaster(minorPlayerID)
local iPlayer = Players[0]
	local reservedCS = load(iPlayer,"ReservedCS")
	if reservedCS[minorPlayerID] and reservedCS[minorPlayerID].Reference then
		return reservedCS[minorPlayerID].Reference
	else
		return nil
	end
end

function IsRebellingAgainst(minorPlayerID, playerID)
local iPlayer = Players[0]
local pPlayer = Players[playerID]
print("IsRebellingAgainst playerID", playerID)
print("IsRebellingAgainst pPlayer", pPlayer)
	local reservedCS = load(iPlayer,"ReservedCS")
	print("IsRebellingAgainst reservedCS[minorPlayerID]", reservedCS[minorPlayerID])
	print("IsRebellingAgainst reservedCS[minorPlayerID].Reference", reservedCS[minorPlayerID].Reference)
	if reservedCS[minorPlayerID] and reservedCS[minorPlayerID].Reference == pPlayer then
		return true
	else
		return false
	end
end

function IsRebelling(minorPlayerID)
local iPlayer = Players[0]
	local reservedCS = load(iPlayer,"ReservedCS")
	if reservedCS[minorPlayerID] and reservedCS[minorPlayerID].Action == "REVOLT" then
		return true
	else
		return false
	end
end