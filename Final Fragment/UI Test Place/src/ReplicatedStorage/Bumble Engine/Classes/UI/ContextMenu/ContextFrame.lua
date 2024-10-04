local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedList = require(ReplicatedStorage["Bumble Engine"].Classes.Data.OrderedList)
local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local CollectionSet = require(ReplicatedStorage["Bumble Engine"].Classes.UI.ContextMenu.CollectionSet)
local Spinner = require(ReplicatedStorage["Bumble Engine"].Classes.UI.ContextMenu.Spinner)
local WorldContexts = require(ReplicatedStorage["Bumble Engine"].Configuration.WorldContexts)

local FFDataService = require(ReplicatedStorage["Bumble Engine"].Services.FFDataService)
local MusicService = require(ReplicatedStorage["Bumble Engine"].Services.MusicService)

local Player = game.Players.LocalPlayer
local uiMaxSize = .75
local uiMinSize = .5

--[[ContextFrame: Class for containing all context UI items. Organizes and executes methods of CollectionSet, Collectible and Spinner classes]]

local ContextFrame = {}

ContextFrame.__index = ContextFrame

--METHODS

--[[UpdateData:
Update data in the current set
]]
function ContextFrame:UpdateData()
   
   print("Change in data detected")
   
   self.CurrentSet:Update()
   
   coroutine.wrap(function()
      
      --Name of the world
      self.Instance["Shards Count"].Header.Text = self.CurrentSet.Instance.Name
      
      --Previously known shard count
      self.Instance["Shards Count"].Content.Text = (
         "Shards: " .. 
         #self.CurrentSet.ObtainedShards .. "/" .. 
         #self.CurrentSet.Shards
      )
      
      --Call server for real shard count
      self.CurrentSet.ObtainedShards = FFDataService:MatchDataTable("Collectibles", EngineTools:CSVToArray(WorldContexts[self.CurrentSet.WorldID].Shards))
   
      --Update shard count again
      self.Instance["Shards Count"].Content.Text = (
         "Shards: " .. 
         #self.CurrentSet.ObtainedShards .. "/" .. 
         #self.CurrentSet.Shards
      )
      
   end)()

   if self.Hidden ~= true then
      if self.CurrentLocation + 1 > self.CollectionSets:GetLength() then
         --Fade out the right button
         EngineTools:QuickTween(
            self.Instance.RightButton,
            .25,
            {
               ImageTransparency = 1,
               Visible = false,
               Active = false
            }, 
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.In
         )
      else
         --Fade in the right button
         EngineTools:QuickTween(
            self.Instance.RightButton,
            .25,
            {
               ImageTransparency = 0,
               Visible = true,
               Active = true
            }, 
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.Out
         )      
      end
      
      if self.CurrentLocation - 1 <= 0 then
         --Fade out the left button
         EngineTools:QuickTween(
            self.Instance.LeftButton,
            .25,
            {
               ImageTransparency = 1,
               Visible = false,
               Active = false
            },
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.In
         )
      else
         --Fade in the left button
         EngineTools:QuickTween(
            self.Instance.LeftButton,
            .25,
            {
               ImageTransparency = 0,
               Visible = true,
               Active = true
            },
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.Out
         )
      end
   end
   return
end

--[[MoveForwards:
Move to the next collection set, if there is one
@return {bool} Success - If the frame was able to move
]]
function ContextFrame:MoveForwards()
   if self.Debounce == true then
      return
   end
   local success = false
   
   local newSet = nil
   
   self.CurrentLocation = self.CurrentLocation or self.CollectionSets:GetKey(
      self.CurrentSet.Instance:GetAttribute("WorldID")
   )
   
   if self.CurrentLocation >= self.CollectionSets:GetLength() or self.Hidden == true then
      return success
   end
   self.Debounce = true
   
   newSet = self.CollectionSets:GetItem(self.CurrentLocation + 1)
   
   self.CurrentLocation += 1
   
   self.Spinner:ShiftSpeed(self.SpinnerSpeed - 0.1, .2)
   
   self:ChangeSet(newSet)
   
   success = true
   
   self.Debounce = false
   return success
end

--[[MoveBackwards:
Move to the previous collection set, if there is one
@return {bool} Success - If the frame was able to move
]]

function ContextFrame:MoveBackwards()
   if self.Debounce == true then
      return
   end
   local success = false
   
   local newSet = nil
   
   self.CurrentLocation = self.CurrentLocation or self.CollectionSets:GetKey(
      self.CurrentSet.Instance:GetAttribute("World ID")
   )
   
   
   if self.CurrentLocation <= 1 or self.Hidden == true then
      return success
   end
   self.Debounce = true

   
   newSet = self.CollectionSets:GetItem(self.CurrentLocation - 1)
   
   self.CurrentLocation -= 1
   
   self.Spinner:ShiftSpeed(self.SpinnerSpeed - 0.1, .2)
   
   self:ChangeSet(newSet)
   
   success = true
   self.Debounce = false
   return success
end

--[[ChangeSet:
Change the current collection set, when menu is open
@param {object} newSet - the new collection set
]]
function ContextFrame:ChangeSet(newSet)
   
   self.CurrentSet:Hide()
   
   local oldSet = self.CurrentSet
   
   --EngineTools:FadeTween(oldSet.Instance.Primary, newSet.Instance.Primary, .25, {ImageTransparency = 1}, {ImageTransparency = .5})
   
   EngineTools:QuickTween(oldSet.Instance.Primary, .25, {ImageTransparency = 1})
   
   EngineTools:QuickTween(newSet.Instance.Primary, .25, {ImageTransparency = .3})
   
   --newSet:Update()
   
   newSet:Show()
   
   self.CurrentSet = newSet
   
   self:UpdateData()
   
   return
end

--[[ExpandMenu:
Expand the context menu and it's details
]]
function ContextFrame:ExpandMenu()
      
   local ButtonGoal  = {
      ImageTransparency = 0,
      Visible = true,
      Active = true
   }
   
   --Remove the open button
   
   self.Instance.OpenButton.Visible = false
   self.Instance.OpenButton.Active = false
  
   --Fade in the right button
   EngineTools:QuickTween(self.Instance.RightButton, .25, ButtonGoal, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
   
   --Fade in the left button
   EngineTools:QuickTween(self.Instance.LeftButton, .25, ButtonGoal, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
   
   --Add the close button
   self.Instance.CloseButton.Visible = true
   self.Instance.CloseButton.Active = true
   
   --Change the frame size
   EngineTools:QuickTween(self.Instance, .25, {Size = UDim2.new(uiMaxSize, 0, uiMaxSize, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   
   --Tween out nowPlaying
   EngineTools:QuickTween(
      self.Instance["Now Playing"], 
      0.25,
      {
         GroupTransparency = 1, 
         --Position = self.Instance["Now Playing"].Position + UDim2.new(.15, 0, 0, 0)
         Position = self.HidePosition
      },
      Enum.EasingStyle.Sine,
      Enum.EasingDirection.Out
   )
   
   --Tween in Shard Count
   EngineTools:QuickTween(
      self.Instance["Shards Count"],
      0.25,
      {
         GroupTransparency = 0, 
         --Position = self.Instance["Shards Count"].Position - UDim2.new(.15, 0, 0, 0)
         Position = self.ShowPosition
      },
      Enum.EasingStyle.Sine,
      Enum.EasingDirection.In
   )
   
   self.Spinner:ShiftSpeed(self.SpinnerSpeed, .2)
   
   self.CurrentSet:Show()
   
   self.Hidden = false
   
   self:UpdateData()
   
   return
end

--[[RetractMenu:
Retract the context menu and it's details
]]
function ContextFrame:RetractMenu()
   
   local ButtonGoal  = {
      ImageTransparency = 1,
      Visible = false,
      Active = false
   }
   
   --Remove the close button
   self.Instance.CloseButton.Visible = false
   self.Instance.CloseButton.Active = false
   
   --Fade out the right button
   EngineTools:QuickTween(self.Instance.RightButton, .25, ButtonGoal, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   
   --Fade out the left button
   EngineTools:QuickTween(self.Instance.LeftButton, .25, ButtonGoal, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   
   --Add the open button
   self.Instance.OpenButton.Visible = true
   self.Instance.OpenButton.Active = true
   
   --Change the frame size
   EngineTools:QuickTween(self.Instance, .25, {Size = UDim2.new(uiMinSize, 0, uiMinSize, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   
   --Tween in nowPlaying
   EngineTools:QuickTween(
      self.Instance["Now Playing"], 
      0.25,
      {
         GroupTransparency = 0, 
         --Position = self.Instance["Now Playing"].Position - UDim2.new(.15, 0, 0, 0)
         Position = self.ShowPosition
      },
      Enum.EasingStyle.Sine,
      Enum.EasingDirection.Out
   )
   
   --Tween out Shard Count
   EngineTools:QuickTween(
      self.Instance["Shards Count"],
      0.25,
      {
         GroupTransparency = 1, 
         --Position = self.Instance["Shards Count"].Position + UDim2.new(.15, 0, 0, 0)
         Position = self.HidePosition
      },
      Enum.EasingStyle.Sine,
      Enum.EasingDirection.In
   )
   
   self.Spinner:ShiftSpeed(self.SpinnerSpeed, .2)
   
   self.CurrentSet:Hide()
   
   self.Hidden = true
   
   self:UpdateData()
   
   return
end

   --[[AssignNowPlaying:
Assign the currently playing track
]]
function ContextFrame:AssignNowPlaying()
   local newText = nil
   
   if MusicService.CurrentTrack == nil then
      newText = "None"
   end
   
   newText = MusicService.CurrentTrack.Name
   
   self.Instance["Now Playing"].Content.Text = newText
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
   
   newContextFrame.Debounce = false
   
   newContextFrame.CurrentLocation = nil
   
   newContextFrame.Instance = Player.PlayerGui["In-Game UI"].ContextMenu.Frame
   
   newContextFrame.ShowPosition = newContextFrame.Instance["Now Playing"].Position
   newContextFrame.HidePosition = newContextFrame.Instance["Now Playing"].Position + UDim2.new(.15,0,0,0)
   
   --For indexing the set relative to the current frame
   newContextFrame.CurrentLocation = 0
   
   newContextFrame.CollectionSets = OrderedList.new("Ascending")
   
   newContextFrame.Hidden = true
   
   for ID, context in WorldContexts do
      
      --If player does not have the gameflag for visiting the world
      if FFDataService:MatchFromSet("GameFlags", context.GameFlag) == false then
         continue
      end
      
      local newSet = CollectionSet.new(ID)
      
      newSet.Instance.Name = WorldContexts[ID].Name
      
      --The player does have the flag, create and add the new set
      newContextFrame.CollectionSets:AddItem(ID, newSet)
      
      newSet.Instance.Parent = newContextFrame.Instance.WorldContexts
   end
   
   newContextFrame.Spinner = Spinner.new()
   
   newContextFrame.SpinnerSpeed = .65
   
   --Change to the world default set
   --newContextFrame.CurrentSet = newContextFrame.CollectionSets:GetItemByValue(
   --   ReplicatedStorage["Bumble Engine"]:GetAttribute("World")
   --)
   
   newContextFrame.CurrentSet = newContextFrame.CollectionSets.Contents[
      tostring(ReplicatedStorage["Bumble Engine"]:GetAttribute("World"))
   ]
   
   --newContextFrame.CurrentLocation = newContextFrame.CollectionSets:GetKey(
   --   ReplicatedStorage["Bumble Engine"]:GetAttribute("World")
   --)
   
   --Why would it not be the world lol
   newContextFrame.CurrentLocation = ReplicatedStorage["Bumble Engine"]:GetAttribute("World")
   
   newContextFrame.CurrentSet:Hide()
   
   EngineTools:QuickTween(newContextFrame.CurrentSet.Instance.Primary, .25, {ImageTransparency = .5})
   
   
   
   newContextFrame:UpdateData()
   
   --[[OpenButton:
   Listen to the OpenButton which expands the UI state
   @listener
   @button Frame.OpenButton
   ]]
   newContextFrame.Instance.OpenButton.MouseButton1Click:Connect(function()
      newContextFrame:ExpandMenu()
      return
   end)
   
   --[[CloseButton:
   Listen to the CloseButton which shrinks the UI state
   @listener
   @button Frame.CloseButton
   ]]
   newContextFrame.Instance.CloseButton.MouseButton1Click:Connect(function()
      newContextFrame:RetractMenu()
      return
   end)
   
   --[[LeftButton:
   Listen to the LeftButton which moves to the previous collection set
   @listener
   @button Frame.LeftButton
   ]]
   newContextFrame.Instance.LeftButton.MouseButton1Click:Connect(function()
      newContextFrame:MoveBackwards()
      return
   end)
   
   --[[RightButton:
   Listen to the RightButton which moves to the next collection set
   @listener
   @button Frame.RightButton
   ]]
   newContextFrame.Instance.RightButton.MouseButton1Click:Connect(function()
      newContextFrame:MoveForwards()
      return
   end)
   
   --[[DataRemoteFunction:
   Listen to FFDataService's event for data changes
   @listener
   @event DataRemoteFunction
   ]]
   
   FFDataService.DataRemote.OnClientEvent:Connect(function()
      --newContextFrame.CurrentSet:Update()
      newContextFrame:UpdateData()
   end)
   
   --[[TrackChange:
   Listen to MusicService's event for track changes
   @listener
   @event TrackChange
   ]]
   ReplicatedStorage["TrackChange"].Event:Connect(function()
      newContextFrame:AssignNowPlaying()
   end)
   
   return newContextFrame
end

return ContextFrame