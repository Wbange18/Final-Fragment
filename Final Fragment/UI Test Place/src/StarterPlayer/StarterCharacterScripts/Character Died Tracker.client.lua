local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeathEvent = Instance.new("BindableEvent")
DeathEvent.Name = "Character Died"
DeathEvent.Parent = ReplicatedStorage["Bumble Engine"].Resources

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