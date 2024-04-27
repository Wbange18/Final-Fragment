--[[CLASS DESCRIPTION:
FrameBar objects exist at the top and bottom of the notification scroll frame. They reveal and
hide themselves to show if notifications are above or below them. Their responsibilities are:
Revealing themselves and hiding themselves
]]

local FrameBar = {}
FrameBar.__index = FrameBar

Engine = _G.Engine

--METHODS==============================================================
--[[
The methods here are self explanatory and require no documentation.
]]

function FrameBar:Reveal()
	--Increase the transparency of the detail bars
	for i, child in ipairs(self.Instance:GetChildren()) do
		Engine.Tools:QuickTween(
			child,
			1/4,
			{Visible = true, BackgroundTransparency = 0}
		)
	end

	--Tween the entire bar out
	Engine.Tools:QuickTween(
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
		Engine.Tools:QuickTween(
			child, 
			1/4, 
			{Visible = false, BackgroundTransparency = 1}
		)
	end

	--Tween the entire bar in
	Engine.Tools:QuickTween(
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
@constructor

@return {object} FrameBar
]]
function FrameBar.new(barInstance)
	local newFrameBar = {}
	setmetatable(newFrameBar, FrameBar)
	newFrameBar.Instance = barInstance
	return newFrameBar
end

return FrameBar