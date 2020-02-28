-- animationcheatSHEET
-- Author: Florian
-- DateCreated: 2/28/2020 2:05:03 PM
--------------------------------------------------------------
--[[
local unit = UI.GetHeadSelectedUnit();
local player = Players[Game.GetActivePlayer()];
SetUnitActionCodeDebug(player:GetID(), unit:GetID(), g_UnitAction);
//hello
function()
	g_Unit_Action_Presets =
	{
		IDLE = 1000,
		ATTACK = 1100,
		DEATH = 1200,
		RUN = 1400,
		START_RUN = 10000,
		FORTIFY = 1500,
		BOMBARD_DEFEND = 1280,
		BOMBARD = 1180,
		COMBAT_READY = 1600,
		ATTACK_CHARGE = 1140,
		RUN_CHARGE = 1120,
		WORK = 1900,
		SHOVEL = 1910,
		RAKE = 1920,
		AXE = 1930,
		PICKAXE = 1940,
		HAMMER = 1950,
		CAPTURED = 1195,
		ACTIVATE = 1990,
		SHUFFLE = 1450,
	 ATTACK_ANIT_AIR = 1130
	}
	
	local presetNames = {}
	local iCount = 0;
	for k, v in pairs(g_Unit_Action_Presets) do
		iCount = iCount + 1;
		presetNames[iCount] = k;
	end
	
	return presetNames;
end
]]