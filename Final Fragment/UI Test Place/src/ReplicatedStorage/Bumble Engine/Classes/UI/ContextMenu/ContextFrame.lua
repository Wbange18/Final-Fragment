local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedList = require(ReplicatedStorage["Bumble Engine"].Classes.Data.OrderedList)
local Spinner = require(ReplicatedStorage["Bumble Engine"].Classes.UI.ContextMenu.Spinner)
local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)
local FFDataService = require(ReplicatedStorage["Bumble Engine"].Services.FFDataService)
local MusicService = require(ReplicatedStorage["Bumble Engine"].Services.MusicService)

--[[ContextFrame: Class for containing all context UI items. Organizes and executes methods of CollectionSet, Collectible and Spinner classes]]

local ContextFrame = {}

ContextFrame.__index = ContextFrame

--METHODS

--[[UpdateData:
Update data in the current set
]]
function ContextFrame:UpdateData()
   
   self.Instance.Frame["Shards Count"].Content.Text = (
      "Shards: " .. 
      #self.CurrentSet.ObtainedShards .. "/" .. 
      #self.CurrentSet.Shards
   )
   
   return
end

--[[MoveForwards:
Move to the next collection set, if there is one
@return {bool} Success - If the frame was able to move
]]
function ContextFrame:MoveForwards()
   local success = false
   
   local newSet = nil
   
   --TODO: Find next set, return if none exist
   
   self:ChangeSet(newSet)
   
   return success
end

--[[MoveBackwards:
Move to the previous collection set, if there is one
@return {bool} Success - If the frame was able to move
]]

function ContextFrame:MoveBackwards()
   local success = false
   
   local newSet = nil
   
   --TODO: Find previous set, return if none exist
   
   self:ChangeSet(newSet)
   
   return success
end

--[[ChangeSet:
Change the current collection set
@param {object} newSet - the new collection set
]]
function ContextFrame:ChangeSet(newSet)
   local oldSet = self.CurrentSet
   
   if oldSet ~= nil then
      oldSet:Hide()
   end
   
   newSet:Show()
   
   self.CurrentSet = newSet
   
   self:UpdateData()
   
   return
end


   --[[AssignNowPlaying:
Assign the currently playing track
]]
function ContextFrame:AssignNowPlaying()
   local newText = nil
   
   if MusicService.CurrentTrack == nil then
      newText = "Now Playing: None"
   end
   
   newText = "Now Playing: " .. MusicService.CurrentTrack.Name
   
   self.Instance.Frame["Now Playing"].Content.Text = newText
   return
end

--CONSTRUCTORS

--[[new:
Create a new context frame. This only happens once, as the context frame is persistent
]]
function ContextFrame.new()
   local newContextFrame = {}
   
   setmetatable(newContextFrame, ContextFrame)
   
   --For executing methods of the current set
   newContextFrame.CurrentSet = nil
   
   --For indexing the set relative to the current frame
   newContextFrame.CurrentSetKey = 0
   
   newContextFrame.CollectionSets = OrderedList.new("Ascending")
   
   --Compile list of CollectionSets available
   for i, collectionSet in ipairs(newContextFrame.Instance.CollectionSets:GetChildren()) do
      if FFDataService:MatchFromSet("GameFlags", collectionSet:GetAttribute("GameFlag")) == true then
         newContextFrame.CollectionSets:AddItem(collectionSet:GetAttribute("WorldID"), collectionSet)
      end
   end
   
   ContextFrame.Spinner = Spinner.new()
   
   --[[TrackChange:
   Listen to MusicService's event for track changes
   @listener
   @event TrackChange
   ]]
   Engine:GetResource("TrackChange").Event:Connect(function()
      newContextFrame:AssignNowPlaying()
   end)
   
   return newContextFrame
end

return ContextFrame