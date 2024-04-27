local MECHANIC = {}

MECHANIC.__index = MECHANIC
setmetatable(MECHANIC, MECHANIC)

MECHANIC.Running = false

function MECHANIC:Run()
	if self.Running == true then
		return
	end
	self.Running = true

end

function MECHANIC:Yield()
	if self.Running == false then
		return
	end
	self.Running = false
end

function MECHANIC.new(model)
	local newMECHANIC = {}
	setmetatable(newMECHANIC, MECHANIC)
	
	MECHANIC.Instance = model
	MECHANIC.Player = game.Players.LocalPlayer
	MECHANIC.Character = MECHANIC.Player.Character
	
	return newMECHANIC
end


return MECHANIC