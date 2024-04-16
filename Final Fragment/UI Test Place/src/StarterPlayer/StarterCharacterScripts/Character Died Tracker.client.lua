local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeathEvent = ReplicatedStorage["🐝 Engine"].Resources.Events["Character Died"]

script.Parent.Humanoid.Died:Connect(function()
	DeathEvent:Fire()
end)

script.Parent.Changed:Connect(function()
	if script.Parent == nil then
		DeathEvent:Fire()
		script.Disabled = true
		script:Destroy()
	end
end)