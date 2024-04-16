local DataSet = {}

DataSet.__index = DataSet

--METHODS==============================================================

--[[AddData
Add data to the data table.
@method
@param {string} dataValue - Value to add to the set of data
@return {bool} Result - Whether or not the operation was successful
]]
function DataSet:AddData(dataValue)
	table.insert(self.Data, dataValue)
	return true
end

--[[RemoveData
Remove data from the data table.
@method
@param {string} dataValue - Value to remove from the set of data
@param {bool} keepRemainder - Optional parameter to preserve identical data copies. False by default
@return {bool} Result - Whether or not the operation was successful
]]
function DataSet:RemoveData(dataValue, keepRemainder)
	keepRemainder = keepRemainder or (keepRemainder == nil and false) --Default parameter is false
	if keepRemainder == true then
		table.remove(self.Data, table.find(self.Data, dataValue))
		return true
	end

	if keepRemainder == false then
		local currentValue = table.find(self.Data, dataValue)
		while currentValue ~= nil do
			table.remove(self.Data, currentValue)
			currentValue = table.find(self.Data, dataValue)
		end
		return true
	end
end

--[[MatchData
Match the data with the specified name and value.
@method
@param {string} dataValue - Name of the value to check
@return {bool} Result - Whether or not the operation was successful
]]
function DataSet:MatchData(dataValue)
	if table.find(self.Data, dataValue) then
		return true
	end
	return false
end

--CONSTRUCTORS========================================================

--[[new
Create a new Data Set for a given player
@constructor
@param {object} Player - The player the data set is for
@param {string} dataName - Name for the data set
]]
function DataSet.new(Player, dataName)
	local newDataSet = {}
	setmetatable(newDataSet, DataSet)
	
	newDataSet.Data = {}
	
	newDataSet.Name = dataName
	return newDataSet
end

return DataSet

