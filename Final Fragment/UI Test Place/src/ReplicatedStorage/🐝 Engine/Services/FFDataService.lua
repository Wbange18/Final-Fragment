local Engine = _G.Engine
local RobloxServices = _G.RobloxServices
local Resources = Engine.Resources
local Classes = Engine.Classes
local Services = Engine.Services

local ReplicatedStorage = RobloxServices.ReplicatedStorage
local RunService = RobloxServices.RunService
local DataStoreService = RobloxServices.DataStoreService
local HttpService = RobloxServices.HttpService
local DataSet = Classes["Data Set"]
local DataStructureList = require(Resources.Lists["Data Structure"])
local DataService = {}
DataService.__index = DataService
DataService.Remote = nil
DataService.PlayerDataPacks = {}
DataService.DataStores = {}

local PlayerDataClass

if RunService:IsClient() then
	DataService.DataRemote = ReplicatedStorage:WaitForChild("DataEvent")
	DataService.RemoteFunction = ReplicatedStorage:WaitForChild("DataRemoteFunction")
end

--METHODS==============================================================

--[[SaveData
Save data to the datastore, iterating through all data sets in the data.
@method
]]
function DataService:SaveData(PlayerData)

	for _, dataSetName in ipairs(DataStructureList) do
		local Data = HttpService:JSONEncode(PlayerData.DataSets[dataSetName].Data)
		local success, errorMessage = pcall(function()
			DataService.DataStores[dataSetName]:SetAsync(PlayerData.Player.UserId, Data)
		end)
		if not success then
			print(errorMessage)
		end
	end
end

--[[LoadData
Load data from the datastore, iterating through all data sets or creating new ones. 
@method
@param {object} PlayerData - PlayerData to load data into
]]
function DataService:LoadData(PlayerData)
	
	for _, dataSetName in ipairs(DataStructureList) do
		PlayerData.DataSets[dataSetName] = 
			DataSet.new(PlayerData.Player, dataSetName)
		local Data = 
			DataService.DataStores[dataSetName]:GetAsync(PlayerData.Player.UserId)
		if Data then
			local success, errorMessage = pcall(function()
				Data = HttpService:JSONDecode(Data)
			end)
			if not success then
				print("CLASSIC DATA DETECTED! Please send this report to Galvarino if this issue persists. In order to fix this issue, your data will be wiped. A record of the purged data will also be reported. Wiping your data... Data = " .. Data .. " ERROR: " .. errorMessage)
				Data = {}
			end
			PlayerData.DataSets[dataSetName].Data = Data
		else
			PlayerData.DataSets[dataSetName].Data = {}
		end
	end
end

--[[RemovePlayerData
Remove player data from the server.
@method {server}
@param {object} PlayerData - Playerdata to remove.
]]
function DataService:RemovePlayerData(PlayerData)
	DataService.PlayerDataPacks[PlayerData.Player.UserId] = nil
	PlayerData = nil
end

--[[AddToSet
Add data to a set.
@method
]]
function DataService:AddToSet(dataName, dataValue, Player)
	if RunService:IsClient() then
		return self.RemoteFunction:InvokeServer("AddToSet", dataName, dataValue)
	end
	local result = self.PlayerDataPacks[Player.UserId]:AddToSet(dataName, dataValue)
	if result == true then
		self.DataRemote:FireClient(Player)
	end
	return result
end

--[[RemoveFromSet
Remove data from a set.
@method
]]
function DataService:RemoveFromSet(dataName, dataValue, Player)
	if RunService:IsClient() then
		return self.RemoteFunction:InvokeServer("RemoveFromSet", dataName, dataValue)
	end
	local result = self.PlayerDataPacks[Player.UserId]:RemoveFromSet(dataName, dataValue)
	if result == true then
		self.DataRemote:FireClient(Player)
	end
	return result
end

--[[MatchFromSet
Match data from a set.
@method
]]
function DataService:MatchFromSet(dataName, dataValue, Player)
	if RunService:IsClient() then
		return self.RemoteFunction:InvokeServer("MatchFromSet", dataName, dataValue)
	end
	local result = self.PlayerDataPacks[Player.UserId]:MatchFromSet(dataName, dataValue)
	return result
end

--[[LeaderStats
Iterate through data sets and determine leader stats.
@method
]]

--SERVER===============================================================

if RunService:IsServer() then
	PlayerDataClass = Classes["Player Data"]
	DataService.DataRemote = Engine.Tools:CreateRemote("DataEvent")
	--This must be required after the data remote is created, as it depends on the remote existing to
	--initialize. Should no longer be an issue with require multithread.
	
	--Remote to fire when data is significantly changed

	for _, dataSetName in ipairs(DataStructureList) do
		DataService.DataStores[dataSetName] = DataStoreService:GetDataStore(dataSetName)
	end

	DataService.RemoteFunction = Engine.Tools:CreateRemoteFunction("DataRemoteFunction")

	--Define a function directory to reduce per-event workload
	local directory = {
		["AddToSet"] = function(dataName, dataValue, Player)
			return DataService:AddToSet(
				dataName, dataValue, Player
			)
		end,
		["RemoveFromSet"] = function(dataName, dataValue, Player)
			return DataService:RemoveFromSet(
				dataName, dataValue, Player
			)
		end,
		["MatchFromSet"] = function(dataName, dataValue, Player)
			return DataService:MatchFromSet(
				dataName, dataValue, Player
			)
		end
	}

	--Attach to remote function
	DataService.RemoteFunction.OnServerInvoke = function(
		Player, targetFunction, dataName, dataValue
	)
		local result = directory[targetFunction](dataName, dataValue, Player)
		return result
	end

	game.Players.PlayerAdded:Connect(function(Player)

		--Create new playerdata from the Class
		local PlayerData = PlayerDataClass.new(Player)

		--Parent to DataService
		DataService.PlayerDataPacks[Player.UserId] = PlayerData

		DataService:LoadData(PlayerData)
		DataService:SaveData(PlayerData)

		game.Players.PlayerRemoving:Connect(function()
			DataService:SaveData(PlayerData)
			DataService:RemovePlayerData(PlayerData)
		end)

		game:BindToClose(function()
			DataService:SaveData(PlayerData)
			DataService:RemovePlayerData(PlayerData)
		end)
	end)
end

return DataService