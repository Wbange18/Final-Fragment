local ReplicatedStorage = _G.RobloxServices.ReplicatedStorage
local RunService = _G.RobloxServices.RunService

local AccessoryService = {}

local Bumble = _G.Bumble

local Engine = _G.Engine

AccessoryService.__index = AccessoryService

if RunService:IsServer() then
	AccessoryService.RemoteFunction = Engine.Tools:CreateRemoteFunction("AccessoryRemoteFunction")
end

if RunService:IsClient() then
	AccessoryService.RemoteFunction = ReplicatedStorage:WaitForChild("AccessoryRemoteFunction")
end

--METHODS==============================================================

--[[AddAccessory
Add an accessory to a player.
@method {client}
@param {instance} accessory - Acessory to add to the player
@param {instance} player - Player to add the accessory to
@param {bool} createM6D - Optional argument to make a motor6D rather than a weld
]]
function AccessoryService:AddAccessory(accessory, createM6D, player)
	createM6D = createM6D or (createM6D == nil and false) --Default parameter is false
	if RunService:IsClient() then
		local newAccessory = self.RemoteFunction:InvokeServer("Add", accessory, createM6D)
		return newAccessory
	end
	
	local newAccessory = accessory:Clone()
	player.Character.Humanoid:AddAccessory(newAccessory)
	
	if createM6D == true then
		Engine.Tools:WeldToM6D(newAccessory.Handle.AccessoryWeld)
	end
	
	return newAccessory
end

--[[RemoveAccessory
Remove an accessory from a player.
@method {client}
]]
function AccessoryService:RemoveAccessory(accessory)
	if RunService:IsClient() then
		return self.RemoteFunction:InvokeServer("Remove", accessory)
	end
	
	accessory:Destroy()
	return true
end

--SERVER===============================================================

if RunService:IsServer() then
	local directory = {
		["Add"] = function(accessory, createM6D, player)
			return AccessoryService:AddAccessory(accessory, createM6D, player)
		end,
		["Remove"] = function(accessory)
			return AccessoryService:RemoveAccessory(accessory)
		end
	}
	AccessoryService.RemoteFunction.OnServerInvoke = 
		function(player, targetFunction, accessory, createM6D)
		local result = directory[targetFunction](accessory, createM6D, player)
		return result
	end
	
end

return AccessoryService