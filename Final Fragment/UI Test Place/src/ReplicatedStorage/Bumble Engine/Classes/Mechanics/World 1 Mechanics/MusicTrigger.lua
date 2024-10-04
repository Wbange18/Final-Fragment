local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MusicService = require(ReplicatedStorage["Bumble Engine"].Services.MusicService)
local MusicTrigger = {}

MusicTrigger.__index = MusicTrigger

MusicTrigger.Running = false


function MusicTrigger:Run()
	if self.Running == true then
		return
	end
	self.Running = true
	
	self.Connection = self.Instance.Touched:Connect(function(Part)
		if Part:IsA("BasePart") and Part:FindFirstAncestorWhichIsA("Accessory") == nil and
			Part:FindFirstAncestorWhichIsA("Model").name == self.Player.name
		then
			MusicService:Play(self.Track, self.FadeTime)
		end
		if Part:IsA("BasePart") and Part.Name == "Handle" and Part:FindFirstAncestorWhichIsA("Accessory").Name == "Marble" then
			MusicService:Play(self.Track, self.FadeTime)
		end
	end)
end


function MusicTrigger:Yield()
	if self.Running == false then
		return
	end
	self.Connection:Disconnect()
	self.Running = false
end


function MusicTrigger.new(model)
	local newMusicTrigger = {}
	setmetatable(newMusicTrigger, MusicTrigger)
	
	newMusicTrigger.Instance = model
	newMusicTrigger.Instance.CollisionGroup = "TouchParts"
	
	newMusicTrigger.Player = game.Players.LocalPlayer
	
	newMusicTrigger.Character = newMusicTrigger.Player.Character
	
	newMusicTrigger.Track = newMusicTrigger.Instance.Track.Value
	
	newMusicTrigger.FadeTime = newMusicTrigger.Instance.Configuration:GetAttribute("FadeTime")
	
	--Create blank connection to touched in case it must be disconnected.
	newMusicTrigger.Connection = newMusicTrigger.Instance.Touched:Connect(function()
	end)
	
	return newMusicTrigger
end


return MusicTrigger