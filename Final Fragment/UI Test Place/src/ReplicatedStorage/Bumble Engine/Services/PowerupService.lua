local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)
local PowerupDescriptions = require(ReplicatedStorage["Bumble Engine"].Resources.Lists.PowerupDescriptions)
local FFNotificationService = require(ReplicatedStorage["Bumble Engine"].Services.FFNotificationService)

local PowerupService = {}

PowerupService.Powerups = {}

PowerupService.RunningPowerups = {}

--METHODS==============================================================

--[[GivePowerup
Give the player a powerup.
@param {string} Powerup - Name of the powerup to give the player.
@param {bool} deathPersistent - If the powerup will reinstate itself on death, until the powerup 
is manually canceled.
@param {bool} cancellable - If the powerup can be manually canceled.
@param {string} duration - Time the powerup will last.
@param {bool} timer - Whether or not to show the timer in the notification.
]]
function PowerupService:GivePowerup(Powerup, cancellable, duration, timerVisible, callback)
	duration = duration or 10
	local PowerupObject = nil
	local compatiblePowerup = true
	local powerupDescription = PowerupDescriptions[Powerup]
	self.callback = callback
	
	if self.RunningPowerups[Powerup] ~= nil then
		return
	end
	
	--For all running powerups, check their compatibility table to see if the new powerup is allowed.
	for _, runningPowerup in ipairs(self.RunningPowerups) do
		for _, name in ipairs(runningPowerup.incompatibility) do
			if Powerup == name then
				compatiblePowerup = false
			end
		end
	end
	
	if compatiblePowerup ~= true then
		return
	end
	
	PowerupObject = Engine.Classes[Powerup].new()
	self.RunningPowerups[Powerup] = PowerupObject
	
	--Callback function to pass to the notification service
	local function powerupDestroyed()
		self:RemovePowerup(Powerup)
	end
	

	FFNotificationService:CreateNotification(
		Powerup, "", duration, timerVisible, cancellable, powerupDescription, "First", nil, powerupDestroyed
	)


	PowerupObject:Run()
	
	return PowerupObject
end

--[[RemovePowerup
Remove a powerup from the player.

@param {string} Powerup - Name of the powerup to remove from the player.
]]
function PowerupService:RemovePowerup(Powerup, died)
	
	local PowerupObject = self.RunningPowerups[Powerup]
	
	--Should be deprecated because of callbacks to the notification service
	--PowerupEvent:Fire(Powerup, false)
	
	if PowerupObject == nil then
		return
	end
	
	PowerupObject:Yield()
	
	self.RunningPowerups[Powerup] = nil
	
	if died == true then
		return 
	end

	for _, Accessory in ipairs(PowerupObject.Accessories) do
		Accessory:Destroy()
	end
	self.callback()
end

--DEFINITION==========================================================

--BELOW SHOULD BE DEPRECATED AS OF V3.0
--for _, module in ipairs(Bumble.Classes.Powerups:GetChildren()) do
--	if module:IsA("ModuleScript") then
--		PowerupService.Powerups[module.Name] = require(module)
--	end
--end

return PowerupService