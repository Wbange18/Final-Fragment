local Engine = _G.Engine

local Powerup = {}

local PowerupService = Engine.Services.PowerupService

local PowerupEvent = Engine:GetResource("Powerup Event")

Powerup.__index = Powerup

Powerup.Running = false

function Powerup:Run()
	if self.Running == true then
		return
	end
	self.Running = true
	
	self.Connection = self.Instance.Pad.Touched:Connect(function()
		if self.Debounce == true then
			return
		end
		self.Debounce = true
		PowerupService:GivePowerup(self.Name, self.Cancellable, self.Duration, self.ShowTimer)
		PowerupEvent.Event:Wait()
		task.wait(.25)
		self.Debounce = false
	end)

end

function Powerup:Yield()
	if self.Running == false then
		return
	end
	self.Running = false
	self.Connection:Disconnect()
end

function Powerup.new(model)
	local newPowerup = {}
	setmetatable(newPowerup, Powerup)
	
	newPowerup.Instance = model
	newPowerup.Player = game.Players.LocalPlayer
	newPowerup.Name = newPowerup.Instance:GetAttribute("Powerup")
	newPowerup.Duration = newPowerup.Instance:GetAttribute("Duration")
	newPowerup.Cancellable = newPowerup.Instance:GetAttribute("Cancellable")
	newPowerup.ShowTimer = newPowerup.Instance:GetAttribute("ShowTimer")
	newPowerup.Debounce = false
	newPowerup.Connection = newPowerup.Instance.Pad.Touched:Connect(function()
	end)
	
	return newPowerup
end


return Powerup