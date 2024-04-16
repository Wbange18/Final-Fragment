local Engine = _G.Engine

--Get Services and Classes
local Splice = Engine.Classes.Splice

local AnimationService = {}

AnimationService.__index = AnimationService

AnimationService.Splices = {}

--METHODS=====================================================================

--[[PlaySplice
Play a given splice, and create it if necessary.
@method
@param {instance} animation - Animation to play
@param {number} animBase - Base of the animation
@param {number} animTime - Duration of the animation
@param {instance} player - Player to play the animation from [Optional]
@param {instance} animator - Animator to run the animation from [Optional]
]]
function AnimationService:PlaySplice(animation, animBase, animTime, player, animator)
	--Create the splice if it doesn't exist
	if not self.Splices[animation.Name] then
		self.Splices[animation.Name] = Splice.new(animation, player, animator)
	end
	
	self.Splices[animation.Name]:Play(animBase, animTime)
	
	return
end

--[[StopSplice
Stop a given splice, and destroy it.
@method
@param {instance} animation - Animation of the splice to stop
]]
function AnimationService:StopSplice(animation)
	if self.Splices[animation.Name] then
		self.Splices[animation.Name]:Remove()
		self.Splices[animation.Name] = nil
	end
	
	return
end

return AnimationService