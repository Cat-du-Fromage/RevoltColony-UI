-- RevoltUtils
-- Author: Florian
-- DateCreated: 2/19/2020 6:29:49 PM
--------------------------------------------------------------
--------------------------------------------------------------
-- Load / Save 
--------------------------------------------------------------
function LoadData( name, defaultValue, key )
	-- a enlever
	local startTime = os.clock()
	--
	local plotKey = key or DEFAULT_SAVE_KEY
	local pPlot = GetPlotFromKey ( plotKey )
	if pPlot then
		local value = load( pPlot, name ) or defaultValue
		-- a enlever
		local endTime = os.clock()
		local totalTime = endTime - startTime
		print ("LoadData() used " .. tostring(totalTime) .. " sec to retrieve " .. tostring(name) .. " from plot " .. tostring(plotKey) .. " (#entries = " .. tostring(GetSize(value)) ..")")
		---
		return value
	else
		print("ERROR: trying to load script data from invalid plot (" .. tostring(plotKey) .."), data = " .. tostring(name))
		return nil
	end
end
function SaveData( name, value, key )
	local startTime = os.clock()
	local plotKey = key or DEFAULT_SAVE_KEY
	local pPlot = GetPlotFromKey ( plotKey )	
	if pPlot then
		save( pPlot, name, value )
		local endTime = os.clock()
		local totalTime = endTime - startTime
		print ("SaveData() used " .. tostring(totalTime) .. " sec to store " .. tostring(name) .. " in plot " .. tostring(plotKey) .. " (#entries = " .. tostring(GetSize(value)) ..")")
	else
		print("ERROR: trying to save script data to invalid plot (" .. tostring(plotKey) .."), data = " .. tostring(name) .. " value = " .. tostring(value))
	end
end

function LoadModdingData( name, defaultValue)
	local startTime = os.clock()
	local savedData = Modding.OpenSaveData()
	local value = savedData.GetValue(name) or defaultValue
	local endTime = os.clock()
	local totalTime = endTime - startTime
	print ("LoadData() used " .. totalTime .. " sec for " .. name)
	print("-------------------------------------")
	return value
end
function SaveModdingData( name, value )
	startTime = os.clock()
	local savedData = Modding.OpenSaveData()
	savedData.SetValue(name, value)
	endTime = os.clock()
	totalTime = endTime - startTime
	print ("SaveData() used " .. totalTime .. " sec for " .. name)
	print("-------------------------------------")
end