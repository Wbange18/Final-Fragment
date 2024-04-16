--[[
This is a client sided module. If first required on a server script, behavior will be
unpredictable. Additionally, a localized NotificationService must exist on the client. 🐝
]]
local Player = game.Players.LocalPlayer

--Get Roblox Services
local TweenService = game:GetService("TweenService")
local ReplicatedService = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--Get Bumble Engine
local Bumble = ReplicatedService["🐝 Engine"]

--Get Bumble Engine Module
local Engine = require(Bumble.Engine)

WorldMechanics = {}

--Tabulate child modules. This also requires them, and thus they are initially called
--and defined here.
for _, module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") and module:GetAttribute("Inactive") == nil then
		WorldMechanics[module.Name] = require(module)
	end
end

return WorldMechanics