local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)

local FrameBar = {}
FrameBar.__index = FrameBar

--METHODS==============================================================
--[[
The methods here are self explanatory and require no documentation.
]]

function FrameBar:Reveal()
	--Increase the transparency of the detail bars
	for i, child in ipairs(self.Instance:GetChildren()) do
		EngineTools:QuickTween(
			child,
			1/4,
			{Visible = true, BackgroundTransparency = 0}
		)
	end

	--Tween the entire bar out
	EngineTools:QuickTween(
		self.Instance, 1/4, {
			Position = UDim2.new(
				0, 0, 
				self.Instance.Position.Y.Scale, 0
			)
		}
	)
end

function FrameBar:Hide()
	
	--Reduce transparency of the detail bars
	for i, child in ipairs(self.Instance:GetChildren()) do
		EngineTools:QuickTween(
			child, 
			1/4, 
			{Visible = false, BackgroundTransparency = 1}
		)
	end

	--Tween the entire bar in
	EngineTools:QuickTween(
		self.Instance, 1/4, {
			Position = UDim2.new(
				-0.139 * 1, 0, 
				self.Instance.Position.Y.Scale, 0
			)
		}
	)
end

function FrameBar:Destroy()
	self = nil
end

--CONSTRUCTORS========================================================

--[[new
Create a new framebar. Since the instances are already loaded in the frame instance, we only
need to reference them.


@return {object} FrameBar
]]
function FrameBar.new(barInstance)
	local newFrameBar = {}
	setmetatable(newFrameBar, FrameBar)
	newFrameBar.Instance = barInstance
	return newFrameBar
end

return FrameBar