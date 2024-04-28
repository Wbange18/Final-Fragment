local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local FFNotificationService = require(ReplicatedStorage["Bumble Engine"].Services.FFNotificationService)
local Collectible = {}

setmetatable(Collectible, Collectible)

Collectible.__index = Collectible

--METHODS

--[[Show
Show the collectible
]]
function Collectible:Show()
   
   EngineTools:QuickTween(
      self.Instance.Piece, 0.5, {ImageColor3 = Color3.new(255,255,255)}, "Sine", "Out"
   )
   
end

--[[Hide
Hide the collectible
]]
function Collectible:Hide()
   
   EngineTools:QuickTween(
      self.Instance.Piece, 0.5, {ImageColor3 = Color3.new(0,0,0)}, "Sine", "Out"
   )
   
end

--[[Focus
Focus the collectible
]]
function Collectible:Focus()
   
end

--[[UnFocus
Unfocus the collectible
]]
function Collectible:UnFocus()
   
end

--CONSTRUCTORS


function Collectible.new()
   
end

return Collectible