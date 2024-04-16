local Engine = _G.Engine

--Get Services and Classes
local Music = Engine.Classes.Music

local MusicService = {}

MusicService.__index = MusicService

MusicService.PlayingTracks = {}

--METHODS=====================================================================

--[[Play
@method
@param {object} Track - Track to play
@param {number} fadeTime - Time to fade to track
]]
function MusicService:Play(Track, fadeTime)
	local TrackObject = Music.Tracks[Track.Name] or Music.new(Track)
	MusicService.PlayingTracks[Track.Name] = TrackObject
	TrackObject:Play()
	TrackObject:Fade("In", TrackObject.FadeTime)
	MusicService:FadeOthers(TrackObject, TrackObject.FadeTime)
	
end

--[[FadeOthers
Fade all other tracks to put in a new one or stop all. 
@method
@param {object} Track - Track to NOT fade
@param {number} fadeTime - Time to fade all other tracks
]]
function MusicService:FadeOthers(Track, fadeTime)
	for _, playingTrack in ipairs(MusicService.PlayingTracks) do
		if playingTrack.Name ~= Track.Name then
			coroutine.wrap(function()
				MusicService.PlayingTracks[playingTrack.Name] = nil
				playingTrack:Fade("Out", playingTrack.FadeTime)
				task.wait(fadeTime)
				if playingTrack.Instance.Volume == 0 then
					playingTrack:Stop()
				end
			end)()
		end
	end
end

--Music service should probably also start itself, here.

return MusicService
