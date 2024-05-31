local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Music = {}
Music.__index = Music

Music.Tracks = {}

--METHODS=====================================================================

--[[Play
Play the music track.

]]
function Music:Play()
	if self.Continue == false then
		self.Instance.TimePosition = self.StartPosition
	end
	self.Instance.Playing = true
	if self.BTime == 0 then
		self.Instance.Looped = true
		return
	end
	coroutine.wrap(function()
		while self.Instance.Playing do
			local steppedConnection
			
			local function TimeUp()
				steppedConnection:Disconnect()
				if self.Instance.Playing == false then
					return
				end
				self.Instance.TimePosition = self.ATime
			end
			
			local steppedDirectory = {
				[-1] = function() return end,
				[0] = TimeUp(),
				[1] = TimeUp()
			}
			local returnFactor
			steppedConnection = RunService.Stepped:Connect(function()
				returnFactor = EngineTools.Flip(EngineTools.BoolToNumber(self.Instance.Playing))
				--If Playing is true, returnFactor = 0 and the loop continues
				--If Playing is false, returnFactor = 1 and the sign is forced to be 1
				steppedDirectory[math.sign((self.Instance.TimePosition + (5000 * returnFactor)) - 
					self.BTime)]()
			end)
		end
	end)()
end

--[[Stop
Stop the music track.

]]
function Music:Stop()
	self.Instance.Playing = false
end

--[[Fade
Fade the music track.

]]
function Music:Fade(direction, fadeTime)
	if direction == "In" then
		EngineTools.QuickTween(self.Instance, fadeTime, {Volume = self.Volume}, Enum.EasingStyle.Linear)
	end
	if direction == "Out" then
		EngineTools.QuickTween(self.Instance, fadeTime, {Volume = 0}, Enum.EasingStyle.Linear)
	end
end

--CONSTRUCTORS===============================================================

function Music.new(SoundObject)
	local newMusic = {}
	setmetatable(newMusic, Music)
	
	newMusic.Name = SoundObject.Name
	newMusic.ATime = SoundObject:GetAttribute("ATime")
	newMusic.BTime = SoundObject:GetAttribute("BTime")
	newMusic.Continue = SoundObject:GetAttribute("Continue")
	newMusic.StartPosition = SoundObject:GetAttribute("StartPosition")
	newMusic.Volume = SoundObject:GetAttribute("Volume")
	newMusic.FadeTime = SoundObject:GetAttribute("FadeTime")
	newMusic.Instance = SoundObject
	
	newMusic.Instance.TimePosition = newMusic.StartPosition
	
	Music.Tracks[newMusic.Name] = newMusic
	
	return newMusic
end

return Music
