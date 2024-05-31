local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Music = require(ReplicatedStorage["Bumble Engine"].Classes.Sounds.Music)
local MusicService = {}

MusicService.__index = MusicService

MusicService.PlayingTracks = {}
MusicService.CurrentTrack = nil

MusicService.TrackChange = EngineTools.CreateRemote("TrackChange")

--METHODS=====================================================================

--[[Play
@param {object} Track - Track to play
@param {number} fadeTime - Time to fade to track
]]
function MusicService:Play(Track, fadeTime)
	local TrackObject = Music.Tracks[Track.Name] or Music.new(Track)
	MusicService.PlayingTracks[Track.Name] = TrackObject
	TrackObject:Play()
	TrackObject:Fade("In", TrackObject.FadeTime)
	MusicService:FadeOthers(TrackObject, TrackObject.FadeTime)
	
	MusicService.CurrentTrack = TrackObject
	
end

--[[FadeOthers
Fade all other tracks to put in a new one or stop all. 
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
