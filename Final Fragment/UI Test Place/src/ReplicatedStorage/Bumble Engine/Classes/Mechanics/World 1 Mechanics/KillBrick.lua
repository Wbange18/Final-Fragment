local KillBrick = {}

KillBrick.__index = KillBrick

KillBrick.Running = false


function KillBrick:Run()
	if self.Running == true then
		return
	end
	self.Running = true
	
	self.Connection = self.Instance.Touched:Connect(function(Part)
		if Part:IsA("BasePart") and Part:FindFirstAncestorWhichIsA("Accessory") == nil and
			Part:FindFirstAncestorWhichIsA("Model").name == self.Player.name
		then
			self.Player.Character.Humanoid.Health = 0
		end
		if Part:IsA("BasePart") and Part.Name == "Handle" and Part:FindFirstAncestorWhichIsA("Accessory").Name == "Marble" then
			self.Player.Character.Humanoid.Health = 0
		end
	end)
end


function KillBrick:Yield()
	if self.Running == false then
		return
	end
	self.Connection:Disconnect()
	self.Running = false
end


function KillBrick.new(model)
	local newKillBrick = {}
	setmetatable(newKillBrick, KillBrick)
	
	newKillBrick.Instance = model
	newKillBrick.Instance.CollisionGroupId = 4
	
	newKillBrick.Player = game.Players.LocalPlayer
	
	newKillBrick.Character = newKillBrick.Player.Character
	
	--Create blank connection to touched in case it must be disconnected.
	newKillBrick.Connection = newKillBrick.Instance.Touched:Connect(function()
	end)
	
	return newKillBrick
end


return KillBrick