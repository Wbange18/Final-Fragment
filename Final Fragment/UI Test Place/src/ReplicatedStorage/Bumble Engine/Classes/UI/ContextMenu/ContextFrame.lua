local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedList = require(ReplicatedStorage["Bumble Engine"].Classes.Data.OrderedList)
local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local CollectionSet = require(ReplicatedStorage["Bumble Engine"].Classes.UI.ContextMenu.CollectionSet)
local Spinner = require(ReplicatedStorage["Bumble Engine"].Classes.UI.ContextMenu.Spinner)
local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)

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
   
   self.Instance.Frame["Shards Count"].Content.Text = (
      "Shards: " .. 
      #self.CurrentSet.ObtainedShards .. "/" .. 
      #self.CurrentSet.Shards
   )
   self.Instance.Frame["Shards Count"].Header.Text = self.CurrentSet.Instance.Name
   
   if self.CurrentLocation + 1 >= self.CollectionSets:GetLength() then
      --Fade out the right button
      EngineTools.QuickTween(
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
      EngineTools.QuickTween(
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
      EngineTools.QuickTween(
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
      EngineTools.QuickTween(
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
   return
end

--[[MoveForwards:
Move to the next collection set, if there is one
@return {bool} Success - If the frame was able to move
]]
function ContextFrame:MoveForwards()
   local success = false
   
   local newSet = nil
   
   self.CurrentLocation = self.CurrentLocation or self.CollectionSets:GetKey(
      self.CurrentSet.Instance:GetAttribute("WorldID")
   )
   
   if self.CurrentLocation <= 0 or self.Hidden == true then
      return success
   end
   
   newSet = self.CollectionSets:GetItem(self.CurrentLocation + 1)
   
   self.CurrentLocation += 1
   
   self:ChangeSet(newSet)
   
   self.Spinner:ChangeSpeed(self.SpinnerSpeed)
   
   success = true
   
   return success
end

--[[MoveBackwards:
Move to the previous collection set, if there is one
@return {bool} Success - If the frame was able to move
]]

function ContextFrame:MoveBackwards()
   local success = false
   
   local newSet = nil
   
   self.CurrentLocation = self.CurrentLocation or self.CollectionSets:GetKey(
      self.CurrentSet.Instance:GetAttribute("World ID")
   )
   
   if self.CurrentLocation >= self.CollectionSets:GetLength() or self.Hidden == true then
      return success
   end
   
   newSet = self.CollectionSets:GetItem(self.CurrentLocation - 1)
   
   self.CurrentLocation -= 1
   
   self:ChangeSet(newSet)
   
   self.Spinner:ChangeSpeed(self.SpinnerSpeed)
   
   success = true
   
   return success
end

--[[ChangeSet:
Change the current collection set, when menu is open
@param {object} newSet - the new collection set
]]
function ContextFrame:ChangeSet(newSet)
   local oldSet = self.CurrentSet
   
   if oldSet ~= nil then
      oldSet:Hide()
   end
   
   newSet:Show()
   
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
   EngineTools.QuickTween(self.Instance.RightButton, .25, ButtonGoal, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
   
   --Fade in the left button
   EngineTools.QuickTween(self.Instance.LeftButton, .25, ButtonGoal, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
   
   --Add the close button
   self.Instance.CloseButton.Visible = true
   self.Instance.CloseButton.Active = true
   
   --Change the frame size
   EngineTools.QuickTween(self.Instance, .25, {Size = UDim2.new(uiMaxSize, 0, uiMaxSize, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   
   --Tween out nowPlaying
   EngineTools.QuickTween(
      self.Instance["Now Playing"], 
      0.25,
      {
         GroupTransparency = 1, 
         Position = self.Instance["Now Playing"].Position + UDim2.new(.15, 0, 0, 0)
      },
      Enum.EasingStyle.Sine,
      Enum.EasingDirection.Out
   )
   
   --Tween in Shard Count
   EngineTools.QuickTween(
      self.Instance["Shards Count"],
      0.25,
      {
         GroupTransparency = 0, 
         Position = self.Instance["Shards Count"].Position - UDim2.new(.15, 0, 0, 0)
      },
      Enum.EasingStyle.Sine,
      Enum.EasingDirection.In
   )
   
   self.Spinner:ChangeSpeed(self.SpinnerSpeed)
   
   self.CurrentSet:Show()
   
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
   EngineTools.QuickTween(self.Instance.RightButton, .25, ButtonGoal, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   
   --Fade out the left button
   EngineTools.QuickTween(self.Instance.LeftButton, .25, ButtonGoal, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   
   --Add the open button
   self.Instance.OpenButton.Visible = true
   self.Instance.OpenButton.Active = true
   
   --Change the frame size
   EngineTools.QuickTween(self.Instance, .25, {Size = UDim2.new(uiMinSize, 0, uiMinSize, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   
   --Tween in nowPlaying
   EngineTools.QuickTween(
      self.Instance["Now Playing"], 
      0.25,
      {
         GroupTransparency = 0, 
         Position = self.Instance["Now Playing"].Position - UDim2.new(.15, 0, 0, 0)
      },
      Enum.EasingStyle.Sine,
      Enum.EasingDirection.Out
   )
   
   --Tween out Shard Count
   EngineTools.QuickTween(
      self.Instance["Shards Count"],
      0.25,
      {
         GroupTransparency = 1, 
         Position = self.Instance["Shards Count"].Position + UDim2.new(.15, 0, 0, 0)
      },
      Enum.EasingStyle.Sine,
      Enum.EasingDirection.In
   )
   
   self.Spinner:ChangeSpeed(self.SpinnerSpeed)
   
   self.CurrentSet:Hide()
   
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
   
   newContextFrame.CurrentLocation = nil
   
   newContextFrame.Instance = Player.PlayerGui["In-Game UI"].ContextMenu.Frame
   
   --For indexing the set relative to the current frame
   newContextFrame.CurrentLocation = 0
   
   newContextFrame.CollectionSets = OrderedList.new("Ascending")
   
   newContextFrame.Hidden = true
   
   --Compile list of CollectionSets available
   for i, collectionSet in ipairs(newContextFrame.Instance.CollectionSets:GetChildren()) do
      if FFDataService:MatchFromSet("GameFlags", collectionSet:GetAttribute("GameFlag")) == true then
         newContextFrame.CollectionSets:AddItem(collectionSet:GetAttribute("WorldID"), CollectionSet.new(collectionSet))
      end
   end
   
   newContextFrame.Spinner = Spinner.new()
   
   newContextFrame.SpinnerSpeed = 10
   
   --Change to the world default set
   newContextFrame.CurrentSet = newContextFrame.CollectionSets:GetItemByValue(
      ReplicatedStorage["Bumble Engine"]:GetAttribute("World")
   )
   
   newContextFrame.CurrentLocation = newContextFrame.CollectionSets:GetKey(
      ReplicatedStorage["Bumble Engine"]:GetAttribute("World")
   )
   
   newContextFrame.CurrentSet:Hide()
   
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
   Engine:GetResource("DataRemoteFunction").Event:Connect(function()
      newContextFrame.CurrentSet:Update()
      newContextFrame:UpdateData()
   end)
   
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