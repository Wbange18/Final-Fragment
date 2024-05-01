local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataSet = require(ReplicatedStorage["Bumble Engine"].Classes.Data.DataSet)
local DataStructure = require(ReplicatedStorage["Bumble Engine"].Resources.Lists.DataStructure)

PlayerData = {}

PlayerData.__index = PlayerData

--METHODS==============================================================

--[[AddToSet
Add data to a set.

]]
function PlayerData:AddToSet(dataName, dataValue)
	local result = self.DataSets[dataName]:AddData(dataValue)
	return result
end

--[[RemoveFromSet
Remove data from a set.

]]
function PlayerData:RemoveFromSet(dataName, dataValue)
	local result = self.DataSets[dataName]:RemoveData(dataValue)
	return result
end

--[[MatchFromSet
Match data from a set.

]]
function PlayerData:MatchFromSet(dataName, dataValue)
	local result = self.DataSets[dataName]:MatchData(dataValue)
	return result
end

--[[WipeSet:
Wipe data from a set.
@param {string} dataName - name of the set to wipe
]]
function PlayerData:WipeSet(dataName)
	local result = self.DataSets[dataName]:WipeSet()
	return result
end


--CONSTRUCTORS========================================================

--[[new
Create a new playerdata set in the module.

]]
function PlayerData.new(Player)
	
	--Construct new data
	local newPlayerData = {}
	setmetatable(newPlayerData, PlayerData)
	
	--Reference Player and create table for child datasets
	newPlayerData.Player = Player
	newPlayerData.DataSets = {}
	
	--Define data sets
	for _, dataSetName in ipairs(DataStructure) do
		newPlayerData.DataSets[dataSetName] = DataSet.new(dataSetName)
	end
	
	return newPlayerData
	
end

return PlayerData