local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Engine_Tools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
Splice = {}

Splice.__index = Splice

--METHODS=====================================================================

--[[Play
Play the splice with given parameters.

@param {number} startKey - Time animation starts from. If negative, the animation will play backwards.
@param {number} endKey - Length of the animation in seconds.
]]
function Splice:Play(startKey, endKey)
	self.animation:AdjustSpeed(0) --Stop any currently occurring animations
	self.startKey = startKey
	
	--Wait for animation to be fully loaded, causes unpredictable behavior otherwise.
	repeat task.wait() until self.animation.Length > 0
	
	--Play the animation
	self.animation:AdjustSpeed(1)
	
	local base = self.animation:GetTimeOfKeyframe(startKey)
	self.animation.TimePosition = base
	
	--Wait for end keyframe
	local endConnection
	endConnection = self.animation:GetMarkerReachedSignal(endKey):Connect(function()
		endConnection:Disconnect()
		
		--Prevent stopping overriding animations
		if self.startKey == startKey then
			self.animation:AdjustSpeed(0)
		end
	end)
end

--[[Destroy
Destroy and stop the splice.

]]
function Splice:Remove()
	self.animation:AdjustSpeed(0) --Stop any currently occurring animations
	self.animation:Stop(0.25)
	self.animation:Destroy()
end

--CONSTRUCTORS===============================================================

--[[new
Create a new splice from a given animation. This will create the animation track in the animator.

@param {instance} animation - The animation to load as a splice
@param {instance} player - Optional player to assign splice animation to
@param {instance} animator - Optional animator object
]]
function Splice.new(animation, player, animator)
	local newSplice = {}
	setmetatable(newSplice, Splice)
	
	if not animator then
		newSplice.animator = Engine_Tools:GetAnimatorFromPlayer(player)
		
	end
	
	newSplice.animation = newSplice.animator:LoadAnimation(animation)
	newSplice.animation:Play(0) --Must occur BEFORE adjusting speed.
	newSplice.animation:AdjustSpeed(0)
	return newSplice
end

return Splice