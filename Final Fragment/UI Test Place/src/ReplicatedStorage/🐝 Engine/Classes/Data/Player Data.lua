--Get Roblox Services
local ReplicatedStorage = _G.RobloxServices.ReplicatedStorage

local Engine = _G.Engine

local DataSet = Engine.Classes["Data Set"]
local DataStructure = require(Engine.Resources.Lists["Data Structure"])

PlayerData = {}

PlayerData.__index = PlayerData

--METHODS==============================================================

--[[AddToSet
Add data to a set.
@method
]]
function PlayerData:AddToSet(dataName, dataValue)
	local result = self.DataSets[dataName]:AddData(dataValue)
	return result
end

--[[RemoveFromSet
Remove data from a set.
@method
]]
function PlayerData:RemoveFromSet(dataName, dataValue)
	local result = self.DataSets[dataName]:RemoveData(dataValue)
	return result
end

--[[MatchFromSet
Match data from a set.
@method
]]
function PlayerData:MatchFromSet(dataName, dataValue)
	local result = self.DataSets[dataName]:MatchData(dataValue)
	return result
end

--CONSTRUCTORS========================================================

--[[new
Create a new playerdata set in the module.
@constructor
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