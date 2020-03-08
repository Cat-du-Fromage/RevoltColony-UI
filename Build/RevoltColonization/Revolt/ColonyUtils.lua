-- ColonyUtils
-- Author: Florian
-- DateCreated: 3/8/2020 7:49:25 PM
--------------------------------------------------------------
include("CSRebels.lua")
local DEFAULT_SAVE_KEY = "1,1"

function LoadData( name, defaultValue, key )
	local plotKey = key or DEFAULT_SAVE_KEY
	local pPlot = GetPlotFromKey ( plotKey )
	if pPlot then
		local value = load( pPlot, name ) or defaultValue
		return value
	else
		return nil
	end
end
function SaveData( name, value, key )
	local plotKey = key or DEFAULT_SAVE_KEY
	local pPlot = GetPlotFromKey ( plotKey )	
	if pPlot then
		save( pPlot, name, value )
	else
	end
end

function LoadModdingData( name, defaultValue)
	local startTime = os.clock()
	local savedData = Modding.OpenSaveData()
	local value = savedData.GetValue(name) or defaultValue
	local endTime = os.clock()
	local totalTime = endTime - startTime
	Dprint ("LoadData() used " .. totalTime .. " sec for " .. name, DEBUG_PERFORMANCE)
	Dprint("-------------------------------------", DEBUG_PERFORMANCE)
	return value
end
function SaveModdingData( name, value )
	startTime = os.clock()
	local savedData = Modding.OpenSaveData()
	savedData.SetValue(name, value)
	endTime = os.clock()
	totalTime = endTime - startTime
	Dprint ("SaveData() used " .. totalTime .. " sec for " .. name, DEBUG_PERFORMANCE)
	Dprint("-------------------------------------", DEBUG_PERFORMANCE)
end

-- return the plot refered by the key string
function GetPlotFromKey ( plotKey )
	local pos = string.find(plotKey, ",")
	local x = string.sub(plotKey, 1 , pos -1)
	local y = string.sub(plotKey, pos +1)
	local plot = Map:GetPlotXY(y,x)
	return plot
end