local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerData = require(ReplicatedStorage["Bumble Engine"].Classes.Data.PlayerData)
local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local DataStructureList = require(ReplicatedStorage["Bumble Engine"].Configuration.DataStructure)

local DataService = {}
DataService.__index = DataService
DataService.Remote = nil
DataService.PlayerDataPacks = {}
DataService.DataStores = {}

if RunService:IsClient() then
	DataService.DataRemote = ReplicatedStorage:WaitForChild("DataEvent")
	DataService.RemoteFunction = ReplicatedStorage:WaitForChild("DataRemoteFunction")
end

--METHODS==============================================================

--[[SaveData
Save data to the datastore, iterating through all data sets in the data.

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

@param {object} PlayerData - PlayerData to load data into
]]
function DataService:LoadData(PlayerData)
	
	for _, dataSetName in ipairs(DataStructureList) do
		--PlayerData.DataSets[dataSetName] = 
		--	DataSet.new(PlayerData.Player, dataSetName)
		local Data = 
			DataService.DataStores[dataSetName]:GetAsync(PlayerData.Player.UserId)
		if Data then
			local success, errorMessage = pcall(function()
				Data = HttpService:JSONDecode(Data)
				if Data == nil then
					Data = {}
				end
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
 {server}
@param {object} PlayerData - Playerdata to remove.
]]
function DataService:RemovePlayerData(PlayerData)
	DataService.PlayerDataPacks[PlayerData.Player.UserId] = nil
	PlayerData = nil
end

--[[SoftWipePlayerData:
Reset a player's game data, excluding settings.
@param {object} PlayerData - Playerdata to wipe
]]
function DataService:SoftWipePlayerData(Player)
	--TODO: COMPLETE THIS Check, 5/31/24; I think its done? Same as below.
	if RunService:IsClient() then
		return self.RemoteFunction:InvokeServer("SoftWipe")
	end
	local result = (
		self.PlayerDataPacks[Player.UserId]:WipeSet("Collectibles") and
		self.PlayerDataPacks[Player.UserId]:WipeSet("GameFlags") and
		self.PlayerDataPacks[Player.UserId]:WipeSet("Swords")
	)
	if result == true then
		self.DataRemote:FireClient(Player)
	end
	return result
end

--[[HardWipePlayerData:
Completely reset a player's data.
@param {object} PlayerData - Playerdata to wipe
]]
function DataService:HardWipePlayerData(Player)
	--TODO: COMPLETE THIS
	if RunService:IsClient() then
		return self.RemoteFunction:InvokeServer("HardWipe")
	end
	local result = false
	for i, setName in ipairs(DataStructureList) do
			
		--Fire the function and compare it to existing result
		result = self.PlayerDataPacks[Player.UserId]:WipeSet(setName) and result
	end
	if result == true then
		self.DataRemote:FireClient(Player)
	end
	return result
end

--[[AddToSet:
Add data to a set.
]]
function DataService:AddToSet(dataName, dataValue, Player)
	if RunService:IsClient() then
		
		--Not looking for data failures, which is problematic. Faster though.
		coroutine.wrap(function()
			self.RemoteFunction:InvokeServer("AddToSet", dataName, dataValue)
		end)
		return
	end
	local result = self.PlayerDataPacks[Player.UserId]:AddToSet(dataName, dataValue)
	if result == true then
		--Fire data remote for significant changes to data
		self.DataRemote:FireClient(Player)
	end
	return result
end

--[[RemoveFromSet:
Remove data from a set.
]]
function DataService:RemoveFromSet(dataName, dataValue, Player)
	if RunService:IsClient() then
		--Not looking for data failures, which is problematic. Faster though.
		coroutine.wrap(function()
			self.RemoteFunction:InvokeServer("RemoveFromSet", dataName, dataValue)
		end)
		return
	end
	local result = self.PlayerDataPacks[Player.UserId]:RemoveFromSet(dataName, dataValue)
	if result == true then
		--Fire data remote for significant changes to data
		self.DataRemote:FireClient(Player)
	end
	return result
end

--[[MatchFromSet:
Match data from a set.
]]
function DataService:MatchFromSet(dataName, dataValue, Player)
	if RunService:IsClient() then
		return self.RemoteFunction:InvokeServer("MatchFromSet", dataName, dataValue)
	end
	local result = self.PlayerDataPacks[Player.UserId]:MatchFromSet(dataName, dataValue)
	return result
end

--[[MatchDataTable:
Match a table of data from the client
@param {table} DataTable - Table of data to check
@param {string} Set - Set of data to check
@return {table} MatchedDataTable - Table of successfully matched data
]]
function DataService:MatchDataTable(Set, DataTable)
	local MatchedDataTable = {}
	for i, value in DataTable do
		if DataService:MatchFromSet(Set, value) == true then
			table.insert(MatchedDataTable, value)
		end
	end
	
	return MatchedDataTable
end

--[[LeaderStats
Iterate through data sets and determine leader stats.

]]

--SERVER===============================================================

if RunService:IsServer() then
	DataService.DataRemote = EngineTools:CreateRemote("DataEvent")
	
	for _, dataSetName in ipairs(DataStructureList) do
		DataService.DataStores[dataSetName] = DataStoreService:GetDataStore(dataSetName)
	end

	DataService.RemoteFunction = EngineTools:CreateRemoteFunction("DataRemoteFunction")

	--Define a function directory for functions called by the remove function handler.
	--Note: parameter order is arbitrary: dataName, dataValue, Player
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
		end,
		["SoftWipe"] = function(_,_,Player)
			return DataService:SoftWipePlayerData(Player)
		end,
		["HardWipe"] = function(_,_,Player)
			return DataService:HardWipePlayerData(Player)
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
		local newPlayerData = PlayerData.new(Player)
		
		--Parent to DataService
		DataService.PlayerDataPacks[Player.UserId] = newPlayerData

		DataService:LoadData(DataService.PlayerDataPacks[Player.UserId])
		
		
		--CLEAN DATA (removes duplicate entries)
		DataService.PlayerDataPacks[Player.UserId]:PolishData()
		
		
		DataService:SaveData(DataService.PlayerDataPacks[Player.UserId])

		game.Players.PlayerRemoving:Connect(function()
			DataService:SaveData(DataService.PlayerDataPacks[Player.UserId])
			DataService:RemovePlayerData(DataService.PlayerDataPacks[Player.UserId])
		end)

		game:BindToClose(function()
			DataService:SaveData(DataService.PlayerDataPacks[Player.UserId])
			DataService:RemovePlayerData(DataService.PlayerDataPacks[Player.UserId])
		end)
	end)
end

return DataService