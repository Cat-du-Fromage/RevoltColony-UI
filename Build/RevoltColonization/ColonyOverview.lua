-- ColonyOverview
-- Author: Florian
-- DateCreated: 12/8/2019 12:10:09 PM
--------------------------------------------------------------
include( "IconSupport" );
include( "InstanceManager" );
include( "TechHelpInclude" );
include("LoyalityFunction.lua")
include("DissidenceFunction.lua")
include("ColonyOverviewOutPut.lua")
include("NewSaveUtils.lua")

local g_ColonyButton = InstanceManager:new( "ColonyButtonInstance", "ColonyButton", Controls.ColonyStack );
WARN_NOT_SHARED = false; include( "SaveUtils" ); MY_MOD_NAME = "RevoltColonization";

--=========================================================================================================
--Open the UI Colony Overview
--=========================================================================================================
function OnOpeningColony()
	ContextPtr:SetHide(false)
end
--=========================================================================================================
--Close the UI Colony Overview
--=========================================================================================================
function OnClosingOK()
  ContextPtr:SetHide(true)
end
--=========================================================================================================
--Closethe UI Colony Overview
--=========================================================================================================

LuaEvents.AdditionalInformationDropdownGatherEntries.Add(function(entries)
table.insert(entries, {
	text = Locale.Lookup("TXT_KEY_COLONY_OVERVIEW"),
	--art = "DC45_Civics.dds", -- icon for EUI
	call = function() 
	    OnOpeningColony() -- function that opens the Popup.
	end,
});
end);

--=========================================================================================================
--Function that allows the use of keyboard as shortcut
--=========================================================================================================
function ColonyInputHandler( uiMsg, wParam, lParam )      
    if(uiMsg == KeyEvents.KeyDown) then
        if (wParam == Keys.VK_ESCAPE) then
			if(Controls.Confirm:IsHidden()) then
				OnClose();
				OnClosingOK()
			else
				Controls.Confirm:SetHide(true);
				Controls.BGBlock:SetHide(false);
			end
            return true;
        end
    end
end
ContextPtr:SetInputHandler( ColonyInputHandler )
--=========================================================================================================
--Function That Set the right icon in the top of the Colony overview's panel
--=========================================================================================================
function ShowHideHandler( bIsHide, bInitState )
	CivIconHookup( Game.GetActivePlayer(), 64, Controls.Icon, Controls.CivIconBG, Controls.CivIconShadow, false, true );
	if( not bInitState ) then
        if( not bIsHide ) then
		UI.incTurnTimerSemaphore();
		Update();
		else
		UI.decTurnTimerSemaphore();
		ResetColonyDescription();
		end
	end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

function TestColonyStarted()
local g_iPlayer = Players[Game.GetActivePlayer()]
local iTech = GameInfoTypes["TECH_COMPASS"]
local renaissance = GameInfo.Eras["ERA_RENAISSANCE"].ID
local tColonyStarted = false
	if g_iPlayer:GetCurrentEra() >= renaissance then
	tColonyStarted = true;
	--print("ColonyStart = vrai")
	else
	tColonyStarted = false
	--print("ColonyStart = faux")
	end
	return tColonyStarted
end

--=========================================================================================================
--Managment of the content of the panel overview
--=========================================================================================================
function ResetColonyDescription()
	Controls.ColonyDescBox:SetHide(true);
end

function Update(g_iPlayer)
	-- Update active player
	local g_iPlayer = Players[Game.GetActivePlayer()]
	local player = Players[g_iPlayer];

	local bColonyStarted = TestColonyStarted();

	Controls.LabelColonyNotStartedYet:SetHide(TestColonyStarted() == true);
	Controls.OverviewPanel:SetHide(TestColonyStarted() == false);
	Controls.NumColonies:SetHide(TestColonyStarted() == false);
	Controls.NumColoniesWorld:SetHide(TestColonyStarted() == false);
	Controls.LabelNoColonies:SetHide( g_iPlayer:CountNumBuildings(GameInfoTypes["BUILDING_JFD_GOVERNORS_MANSION"]) ~= 0);

	if(bColonyStarted) then
		local iTotalColonies = 0;
		--How many colonies in the world
		for PlayerID = 0, GameDefines.MAX_MAJOR_CIVS - 1, 1 do
			if (Players[PlayerID] ~= nil) then
					local pPlayer = Players[PlayerID]
					local numColonies = pPlayer:CountNumBuildings(GameInfoTypes["BUILDING_JFD_GOVERNORS_MANSION"])
					iTotalColonies = iTotalColonies + numColonies
			end
		end
		Controls.NumColoniesWorld:LocalizeAndSetText( "TXT_KEY_NUM_WORLD_COLONIES", iTotalColonies );
		--How Many colonies do i have?
		Controls.NumColonies:LocalizeAndSetText( "TXT_KEY_NUM_OUR_COLONIES", g_iPlayer:CountNumBuildings(GameInfoTypes["BUILDING_JFD_GOVERNORS_MANSION"]) );


		-- Show Colony Information
			UpdateColonyList();
			g_SelectedColony = nil;
	end
end

--=========================================================================================================
--Update List if we have Colonies
--=========================================================================================================

function UpdateColonyList()
	local g_iPlayer = Players[Game.GetActivePlayer()]
	local player = Players[g_iPlayer];
	local numColonies = g_iPlayer:CountNumBuildings(GameInfoTypes["BUILDING_JFD_GOVERNORS_MANSION"])
	if (ContextPtr:IsHidden()) then
		return;
	end
	
	if (IsGameCoreBusy()) then
		return;
	end

	-- Clear buttons
	g_ColonyButton:ResetInstances();

	-- Add Colonies to stack
	for city in g_iPlayer:Cities() do
			if (city:IsColony() == true) then
			--print("ColonyList colony targeted ok")
				-- Our colony?
					local controlTable = g_ColonyButton:GetInstance();

					controlTable.LeaderName:SetText( city:GetName() );

					eCity = city
					local civType = city:GetCivilizationType();
					local originalOwnerID = city:GetOriginalOwner();
					local originalCityOwner = Players[ originalOwnerID ]
					local originOwnerCiv = originalCityOwner:GetCivilizationType();
					local originOwnerCivInfo = GameInfo.Civilizations[civType];
					local civInfo = GameInfo.Civilizations[civType];
					local strCiv = Locale.ConvertTextKey(civInfo.ShortDescription);

					local otherLeaderType = originalCityOwner:GetLeaderType();
					local otherLeaderInfo = GameInfo.Leaders[otherLeaderType];

					controlTable.CivName:SetText(strCiv);
					IconHookup( otherLeaderInfo.PortraitIndex, 64, otherLeaderInfo.IconAtlas, controlTable.LeaderPortrait );
					--Function Selection of a Colony
					controlTable.ColonyButton:SetVoid1(city:GetID()); -- indicates type
					controlTable.ColonyButton:RegisterCallback( Mouse.eLClick, ColonySelected );
			end
	end

	--GENERAL TAXE
	if( CanSetGeneralTaxe(g_iPlayer) == false or numColonies == 0 ) then
	Controls.GeneralTaxSlider:SetDisabled( true );
	Controls.ApplyGeneralChanges:SetDisabled( true );
	--Controls.TaxSliderValueToolTip:LocalizeAndSetToolTip( "TXT_KEY_VO_TAX_TOO_SOON", iNumTurnsForTax, iNumTurnsLeft );
	else
		Controls.GeneralTaxSlider:SetDisabled( false );
		Controls.ApplyGeneralChanges:SetDisabled( false );
		--Controls.TaxSliderValueToolTip:SetToolTipString( "" );
	end
	--[[
	--Current taxe Applied
	if load(g_iPlayer, "TaxeTimer") ~= nil then
	Controls.GeneralTaxSlider:SetValue(load(g_iPlayer, "GeneralTaxeValue"))
	end
	]]
		--Current taxe Applied
	Controls.GeneralTaxSlider:SetValue(GeneralTaxeDummyValue(g_iPlayer))

	-- ON APPLY CHANGE
	--Controls.ApplyGeneralChanges:SetDisabled( true );
	Controls.ApplyGeneralChanges:SetVoid1( g_iPlayer );
	Controls.ApplyGeneralChanges:RegisterCallback( Mouse.eLClick, OnApplyGeneralChangesClicked );
	Controls.ApplyGeneralChanges:LocalizeAndSetToolTip( "TXT_KEY_APPLY_GENERAL_CHANGES_TT" );
	-------------------------------------------------------------------------------------
	Controls.ColonyStack:CalculateSize();

	Controls.ScrollPanel:CalculateInternalSize();
	Controls.ScrollPanel:ReprocessAnchoring();
end

--=========================================================================================================
--Update Colony Details when colony selected
--=========================================================================================================
function ColonySelected( iCity ) -- ID
	if not Players[Game.GetActivePlayer()]:IsTurnActive() or Game.IsProcessingMessages() then
		return;
	end
	if( Controls.ColonyDescBox:IsHidden() ) then
		Controls.ColonyDescBox:SetHide(false);
	end
	--on recupère l'ID du joueur
	local g_iPlayer = Players[Game.GetActivePlayer()];
	--Table de la colony selectionné
	pCity = g_iPlayer:GetCityByID(iCity)
	--local civType = city:GetCivilizationType();
	local originalOwnerID = pCity:GetOriginalOwner();
	local originalCityOwner = Players[ originalOwnerID ]
	local originOwnerCiv = originalCityOwner:GetCivilizationType();
	local originOwnerCivInfo = GameInfo.Civilizations[originOwnerCiv];
	local civInfo = GameInfo.Civilizations[originOwnerCiv];
	local strCiv = Locale.ConvertTextKey(civInfo.ShortDescription);

	local otherLeaderType = originalCityOwner:GetLeaderType();
	local otherLeaderInfo = GameInfo.Leaders[otherLeaderType];
	
	--On met l'icon et le texte dans le details de la colonie
	Controls.ColonyInfoLeaderName:SetText( pCity:GetName() );

	Controls.ColonyInfoCivName:SetText( strCiv );
	Controls.ColonyInfoStarted:LocalizeAndSetText("TXT_KEY_TURNS_ACQUIRED", Game.GetGameTurn() - pCity:GetGameTurnAcquired()  , pCity:GetGameTurnAcquired());

	-- Original Civilization's owner Portrait
	CivIconHookup(originalOwnerID, 128, Controls.ColonySubIcon, Controls.ColonySubIconBG, Controls.ColonySubIconShadow, false, true );
	--
	-- Build Independence tooltip
	--[[
	local strType, strTypeTooltip;
	if( pVassalTeam:IsVoluntaryVassal( g_iTeam ) ) then
		strType = Locale.ConvertTextKey( "TXT_KEY_VO_VASSAL_TYPE_VOLUNTARY" );
		strTypeTooltip = Locale.ConvertTextKey( "TXT_KEY_VO_VASSAL_TYPE_VOLUNTARY_TT" );
	else
		strType = Locale.ConvertTextKey( "TXT_KEY_VO_VASSAL_TYPE_CAPITULATED" );
		strTypeTooltip = Locale.ConvertTextKey( "TXT_KEY_VO_VASSAL_TYPE_CAPITULATED_TT" );
	end

	Controls.VassalInfoType:LocalizeAndSetText(strType);
	Controls.VassalInfoType:LocalizeAndSetToolTip(strTypeTooltip);

	Controls.TaxSlider:SetValue( TaxValueToPercent( g_pTeam:GetVassalTax( ePlayer ) ) );         --NOUS INDIQUE LA TAXE EN COURS
	
	local iNumTurnsForTax = Game.GetMinimumVassalTaxTurns();
	local iNumTurnsSinceSet = g_pTeam:GetNumTurnsSinceVassalTaxSet( ePlayer );
	local iNumTurnsLeft = iNumTurnsForTax - iNumTurnsSinceSet;
	]]
	--[[
			--ETAPE A DEFINIR																	NOUS INDIQUE SI ON PEUT TAXER --> DEFINIR LES CONDITION (SUREMENT LE BATIMENT "TIMER_TAXE")
	if( CanSetGeneralTaxe(g_iPlayer) == false ) then
		Controls.GeneralTaxSlider:SetDisabled( true );
		--Controls.TaxSliderValueToolTip:LocalizeAndSetToolTip( "TXT_KEY_VO_TAX_TOO_SOON", iNumTurnsForTax, iNumTurnsLeft );
	else
		Controls.GeneralTaxSlider:SetDisabled( false );
		--Controls.TaxSliderValueToolTip:SetToolTipString( "" );
	end
	]]
	--[[
	--POSSIBLEMENT NON UTILISE
	local iTurnTaxesSet = Game.GetGameTurn() - iNumTurnsSinceSet;
	local iTurnTaxesAvailable = Game.GetGameTurn() + iNumTurnsLeft;
	local availableStr = "";
	local taxesSetTurnStr = "";
	if ( iNumTurnsLeft <= 0 or iNumTurnsSinceSet == -1 ) then
		availableStr = Locale.ConvertTextKey("TXT_KEY_VO_TAX_CHANGE_READY");
	else
		availableStr = Locale.ConvertTextKey("TXT_KEY_VO_TAX_TURN_AVAILABLE", iTurnTaxesAvailable);
	end

	if ( g_pTeam:GetNumTurnsSinceVassalTaxSet( ePlayer ) == -1 ) then	
		taxesSetTurnStr = Locale.ConvertTextKey("TXT_KEY_VO_TAX_TURN_NOT_SET_EVER");
	else
		taxesSetTurnStr = Locale.ConvertTextKey("TXT_KEY_VO_TAX_TURN_SET", iTurnTaxesSet);
	end

	Controls.TaxesCurrentGPT:LocalizeAndSetText("TXT_KEY_VO_TAX_CONTRIBUTION", g_pPlayer:GetVassalTaxContribution(ePlayer));
	Controls.TaxesCurrentGPT:LocalizeAndSetToolTip("TXT_KEY_VO_TAX_GPT_RECEIVED_TT", g_pPlayer:GetVassalTaxContribution(ePlayer), g_pTeam:GetVassalTax( ePlayer), pVassalPlayer:CalculateGrossGold());

	Controls.TaxesTurnSet:SetText(taxesSetTurnStr);
	Controls.TaxesAvailableTurn:SetText(availableStr);
	Controls.TaxSliderValue:LocalizeAndSetText("TXT_KEY_VO_TAX_RATE", g_pTeam:GetVassalTax( ePlayer ) );
	]]
	DoVassalStatistics( pCity, g_iPlayer );
	--[[
	-- ON APPLY CHANGE
	Controls.ApplyChanges:SetDisabled( true );
	Controls.ApplyChanges:SetVoid1( g_iPlayer );
	Controls.ApplyChanges:RegisterCallback( Mouse.eLClick, OnApplyGeneralChangesClicked );
	Controls.ApplyChanges:LocalizeAndSetToolTip( "TXT_KEY_APPLY_GENERAL_CHANGES_TT" );
	]]

	-- Liberate Vassal button
	local tooltipStr = Locale.ConvertTextKey("TXT_KEY_VO_LIBERATE_COLONY_TT", pCity:GetName());
	Controls.LiberateColony:SetDisabled( false );

	Controls.LiberateColony:SetToolTipString( tooltipStr );
	Controls.LiberateColony:SetVoid1( iCity );
	Controls.LiberateColony:RegisterCallback( Mouse.eLClick, OnLiberateColonyClicked );

	Controls.StatsScrollPanel:CalculateInternalSize();
	Controls.StatsScrollPanel:ReprocessAnchoring();

	Controls.ManagementScrollPanel:CalculateInternalSize();
	Controls.ManagementScrollPanel:ReprocessAnchoring();
end



	LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();
	ContextPtr:SetHide(true);


--=========================================================================================================
-- DISSIDENCE/LOYALITY COLONY UI
--=========================================================================================================
function DoVassalStatistics( pCity, playerID )
local city = pCity
--print("CityID",city)
--local player = city:GetOwner()
local player = playerID
--print("PlayerID", player)
local TotalDissidence = ColonyDissidence(city, player)
local dissidenceConnectionMetropoleBuild = DissidenceConnectionNumBuilding(city, player)
local dissidenceBaseUnHappiness = DissidenceBase(city, player)
local dissidenceGPT = DissidenceGPT(player)
local dissidenceEmpire = DissidenceEmpire(player)
local dissidenceWW = DissidenceWarWeariness(player)
local dissidenceGeneraltaxe = DissidenceGeneralTaxes(player)

local cityYieldGold = city:GetYieldRateTimes100( YieldTypes.YIELD_GOLD ) / 100
local cityYieldScience = city:GetYieldRateTimes100( YieldTypes.YIELD_SCIENCE ) / 100
local cityYieldCulture = city:GetYieldRateTimes100( YieldTypes.YIELD_CULTURE ) / 100

--Loyality
local WLTKDBonus = ColonyWLTKD(player, city)
local GABonus = ColonyGoldenAge(player)
local TradeAny = (TradeRouteAny(player, city))*5
	-- Population Dissidence
	Controls.ColonyStatsPopulation:SetText( city:GetPopulation() );
	Controls.ColonyStatsTotalDissidence:SetText( TotalDissidence );
	Controls.ColonyStatsConnection:SetText( dissidenceConnectionMetropoleBuild );
	Controls.ColonyStatsBaseUnhappy:SetText( dissidenceBaseUnHappiness );
	Controls.ColonyStatsGPT:SetText( dissidenceGPT );
	Controls.ColonyStatsEmpireDissidence:SetText( dissidenceEmpire );
	Controls.ColonyStatsWarWeariness:SetText( dissidenceWW );
	Controls.ColonyStatsGeneralTaxe:SetText( dissidenceGeneraltaxe );

	-- Population Loyality
	Controls.ColonyStatsWLTKD:SetText( WLTKDBonus );
	Controls.ColonyStatsGA:SetText( GABonus );
	Controls.ColonyStatsTradeAny:SetText( TradeAny );

	-- ColonyOutput
	Controls.ColonyStatsGold:SetText(cityYieldGold);
	Controls.ColonyStatsScience:SetText(cityYieldScience);
	Controls.ColonyStatsCulture:SetText(cityYieldCulture);
end
--=========================================================================================================
-- GENERAL COLONY TAXE
--=========================================================================================================
--=========================================================================================================
-- General Colony Tax Slider
--=========================================================================================================
function GeneralTaxSliderUpdate( fValue )

	local iTaxValue = PercentToTaxValue( fValue );
	Controls.GeneralTaxSliderValue:SetText( Locale.ConvertTextKey("TXT_KEY_GENERAL_COLONY_TAX_RATE", iTaxValue) );

	--UpdateApplyChanges();
end
Controls.GeneralTaxSlider:RegisterSliderCallback( GeneralTaxSliderUpdate );

--fonction qui permet de changer les taxes????
--[[
function UpdateApplyChanges()
	Controls.ApplyGeneralChanges:SetDisabled( PercentToTaxValue(Controls.GeneralTaxSlider:GetValue() ) == g_pTeam:GetVassalTax(g_SelectedVassal) );
end
]]
-- convert percentage to tax tvalue
function PercentToTaxValue( fPercent )
	local iMin = 0
	local iMax = 50

	-- desired number of steps we want the meter to grow
	local iStepIncrease = 10;
	local iStepsNeeded = (iMax / iStepIncrease);
	
	fPercent = math.floor( fPercent * iStepsNeeded ) * (1 / iStepsNeeded);
	return fPercent * (iMax - iMin);
end

-- convert Tax Value to percentage from 0.0 to 1.0
function TaxValueToPercent( iTaxValue )
	local iMin = 0
	local iMax = 50
	return math.min(math.max((iTaxValue) / (iMax - iMin), 0), 1);
end

--=========================================================================================================
-- BUTTON CLICKED
--=========================================================================================================
function OnLiberateColonyClicked( cityID )
	local player = Players[Game.GetActivePlayer()];
	local pCity = player:GetCityByID(cityID)
	Controls.ConfirmLabel:LocalizeAndSetText( "TXT_KEY_COLONY_CONFIRM_LIBERATE", pCity:GetName() );
	Controls.Confirm:SetHide( false );
	Controls.BGBlock:SetHide( true );
	
	Controls.Yes:SetVoid1( 0 );
	Controls.Yes:SetVoid2( cityID );
	Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );
end

function OnApplyGeneralChangesClicked( playerID )
	local player = Players[Game.GetActivePlayer()];
	local iTaxValue = PercentToTaxValue( Controls.GeneralTaxSlider:GetValue() );
	local TaxeIncome = (ColoniesGPTConversion(player))*(iTaxValue/100)
	Controls.ConfirmLabel:LocalizeAndSetText( "TXT_KEY_GENERAL_COLONY_CONFIRM_TAX_CHANGE", iTaxValue, TaxeIncome);
	Controls.Confirm:SetHide( false );
	Controls.BGBlock:SetHide( true );
	
	Controls.Yes:SetVoid1( 1 );
	Controls.Yes:SetVoid2( player );
	Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );
end
-----------------------------------------------
--BOUTON CLOSE
-----------------------------------------------
function OnClose()
    UIManager:DequeuePopup( ContextPtr );
	OnClosingOK()
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose);
-----------------------------------------------
--BOUTON OUI
-----------------------------------------------
function OnYes( type, iValue )
	Controls.Confirm:SetHide(true);
	Controls.BGBlock:SetHide(false);
	-- Liberation
	if( type == 0 ) then
		ColonyLiberation( iValue );
		OnClose();
	-- Apply Tax Change
	elseif ( type == 1 ) then
	local player = Players[iValue]
		local iTaxRate = PercentToTaxValue( Controls.GeneralTaxSlider:GetValue() );
		print( "VALEUR TAXE EN %%%% / player", iTaxRate,  player)
		GeneralTaxeTIMER(iValue, iTaxRate)
		--save( player, "GeneralTaxeValue", iTaxRate )
		--DoApplyColonyGeneralTaxe(iValue)
		OnClosingOK()
	end
end
-----------------------------------------------
--BOUTON NON
-----------------------------------------------
function OnNo( )
	Controls.Confirm:SetHide(true);
	Controls.BGBlock:SetHide(false);
end
Controls.No:RegisterCallback( Mouse.eLClick, OnNo );

GameEvents.PlayerDoTurn.Add(TimerGeneralTaxeFade)