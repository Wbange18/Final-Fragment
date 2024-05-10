local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)

--[[Collectible: Single collectible with functionality parented to a CollectionSet class of the ContextFrame class.]]

local Collectible = {}

Collectible.__index = Collectible

--METHODS

--[[Obtain:
Show the collectible
]]
function Collectible:Obtain()
   
   EngineTools:QuickTween(
      self.Instance.Relic, 0.5, {ImageColor3 = Color3.new(255,255,255)},
      Enum.EasingStyle.Sine, Enum.EasingDirection.Out
   )
   return
end

--[[UnObtain:
Hide the collectible
]]
function Collectible:UnObtain()
   
   EngineTools:QuickTween(
      self.Instance.Relic, 0.5, {ImageColor3 = Color3.new(0,0,0)},
      Enum.EasingStyle.Sine, Enum.EasingDirection.Out
   )
   
   return
end

--[[Focus:
Focus the collectible
]]
function Collectible:Focus()
   EngineTools:QuickTween(self.Instance, .15, {Size = UDim2.new(0.8, 0,0.125, 0)}, Enum.EasingDirection.In)
   EngineTools:QuickTween(self.Instance.TextLabel, .15, {TextTransparency = 0}, Enum.EasingDirection.In)
   EngineTools:QuickTween(self.Instance, .15, {BackgroundTransparency = 0}, nil, Enum.EasingDirection.In)
   self.Focused = true
   return
end

--[[UnFocus:
Unfocus the collectible
]]
function Collectible:UnFocus()
   EngineTools:QuickTween(self.Instance, .15, {Size = UDim2.new(0.62, 0,0.1, 0)}, nil, Enum.EasingDirection.Out)
   EngineTools:QuickTween(self.Instance.TextLabel, .15, {TextTransparency = 1}, nil, Enum.EasingDirection.Out)
   EngineTools:QuickTween(self.Instance, .15, {BackgroundTransparency = 1}, nil, Enum.EasingDirection.Out)
   self.Focused = false
   return
end

--[[Fade:
Fade the collectible, when another is hovered
]]
function Collectible:Fade()
   EngineTools:QuickTween(self.Instance, 0.1, {GroupTransparency = .8}, nil, Enum.EasingDirection.In)
   return
end

--[[UnFade:
Unfade the collectible, when none others are hovered
]]
function Collectible:UnFade()
   EngineTools:QuickTween(self.Instance, 0.1, {GroupTransparency = 0}, nil, Enum.EasingDirection.In)
   return
end

--[[Hide:
Completely hide the collectible, tweening to UI center
]]
function Collectible:Hide()
   EngineTools:QuickTween(self.Instance, .25, {GroupTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
   return
end

--[[Show:
Completely show the collectible, tweening to designated UI position
]]
function Collectible:Show()
   EngineTools:QuickTween(self.Instance, .25, {GroupTransparency = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
   return
end

--[[Move:
Move the UI element
@param {UDim2} PositionGoal - PositionGoal to move the UI element to
]]
function Collectible:Move(PositionGoal, easingStyle: UDim2)
   PositionGoal = PositionGoal or self.CenterPosition
  local  style = easingStyle or Enum.EasingDirection.Out
   EngineTools:QuickTween(self.Instance, .25, {Position = PositionGoal}, Enum.EasingStyle.Back, style)
   return
end

--[[Destroy:
Destroy the collectible object
]]
function Collectible:Destroy()
   self.Instance:Destroy()
	self.Value = nil
	self.centerPosition = nil
	self = nil
   return
end

--CONSTRUCTORS

--[[new:
Create a new collectible
@param {string} Data - The data of the collectible, I.E. "R32"
@param {Folder} Parent - Parent folder of the collectible
]]
function Collectible.new(Data: string, Parent: Folder)
   local newCollectible = {}
   setmetatable(newCollectible, Collectible)
   
   newCollectible.Focused = false
   newCollectible.centerPosition = UDim2.new(0.5,0,0.5,0)
   newCollectible.Instance = Engine:GetResource("Reference Relic"):Clone()
   
   newCollectible.Instance.Name = Data
   
   newCollectible.Instance.Parent = Parent
   
   newCollectible.Value = Data
   
   --Initial setup
   newCollectible.Instance.Position = newCollectible.centerPosition
   
   return newCollectible
end

return Collectible