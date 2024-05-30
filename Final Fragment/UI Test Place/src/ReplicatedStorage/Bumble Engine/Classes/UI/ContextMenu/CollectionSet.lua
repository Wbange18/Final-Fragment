local AnimationFromVideoCreatorService = game:GetService("AnimationFromVideoCreatorService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedList = require(ReplicatedStorage["Bumble Engine"].Classes.Data.OrderedList)
local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Collectible = require(ReplicatedStorage["Bumble Engine"].Classes.UI.ContextMenu.Collectible)
local FFDataService = require(ReplicatedStorage["Bumble Engine"].Services.FFDataService)

--[[CollectionSet: Set of Collectible classes and data used to organize data for the ContextFrame class.]]

local CollectionSet = {}

CollectionSet.__index = CollectionSet

--METHODS

--[[Show:
Show the collection set
]]
function CollectionSet:Show()
   
   local angleSubdivision, relicAngle, relicX, relicY, relicPosition
   
   for i, relic in ipairs(self.Relics:GetList()) do
      
      --Get the angle between each piece
      angleSubdivision = (90 - 20) / self.Relics:GetLength()
      
      --Multiply the subdivision by the ordered key of the relic.
      relicAngle = angleSubdivision * self.Relics:GetKey(relic.Value)
      
      --Convert polar to x and y, adding the padding to the angle
      relicX = 0.58 * math.cos(math.rad(relicAngle + 10))
      
      --Y axis is flipped because roblox is cool
      relicY = -0.58 * math.sin(math.rad(relicAngle + 10))
      
      relicPosition = UDim2.new(relicX, 0, relicY, 0)
      
      relic:Move(relicPosition)
      relic:UnHide()
      
      --Recursive function which waits for the mouse to leave, then waits for the mouse to enter.
      local function MouseEnter()
         
         relic.Focus()
         
         relic.Instance.MouseLeave:Once(function()
            
            relic.UnFocus()
            
            --Recurse the function, assigning the connection value.
            relic.connection = relic.Instance.MouseEnter:Once(MouseEnter)
         end)
      end
      
      --Run MouseEnter once when the mouse enters the frame.
      relic.EnterConnection = relic.Instance.MouseEnter:Once(MouseEnter)
      
   end
   
   --Add the preview
   EngineTools.QuickTween(self.Instance.Preview, .25, {ImageTransparency = 0}, nil, Enum.EasingDirection.Out)
   return
end

--[[Hide:
Hide the collection set
]]
function CollectionSet:Hide()
   
   for i, relic in ipairs(self.Relics:GetList()) do
      
      if relic.connection ~= nil then
         relic.connection:Disconnect()
      end
      
      --If first parameter is blank, this uses internal centerposition value
      relic:Move(nil, "In")
      relic:Hide()
      
      --Multithread to avoid delay
      coroutine.wrap(function()
         
         --Time the prior two functions take to complete.
         task.wait(0.25)
         
         --Since self:Update() can create relics, we can destroy them to save memory.
         relic:Destroy()
      end)()
   end
   
   
   
   --Remove the preview
   EngineTools.QuickTween(self.Instance.Preview, .25, {ImageTransparency = 1}, nil, Enum.EasingDirection.In)
   
   return
end

--[[Update:
Update the set in case anything changed, checking if hidden relics are found, and unfading
obtained relics.
]]
function CollectionSet:Update()
   local RelicValues = EngineTools.CSVToArray(self.Folder.Contents:GetAttribute("Relics"))
   
   local HiddenRelicValues = EngineTools.CSVToArray(self.Folder.Contents:GetAttribute("HiddenRelics"))
   
   for i, relic in ipairs(RelicValues) do
      
      --Check if the relic exists in the ordered list
      if self.Relics:GetItemByValue(tonumber(relic)) == nil then
         
         --Create the new collectible and add it to ordered list by relic number
         local newRelic = Collectible.new(relic, self.Folder)
         
         self.Relics:AddItem(tonumber(relic), newRelic)
         
         if FFDataService:MatchFromSet("Collectibles", relic) then
            newRelic:Obtain()
            continue
         end
         
         newRelic:UnObtain()
         continue
      end
      
      local existingRelic = self.Relics:GetItemByValue(tonumber(relic))
      
      if FFDataService:MatchFromSet("Collectibles", relic) then
         existingRelic:Obtain()
         continue
      end
      existingRelic:UnObtain()
      continue
   end
   
   for i, hiddenrelic in ipairs(HiddenRelicValues) do
      local hiddenRelicObject = self.Relics:GetItemByValue(tonumber(hiddenrelic))
      if hiddenRelicObject == nil and FFDataService:MatchFromSet("Collectibles", hiddenrelic) then
            local newHiddenRelic = Collectible.new(hiddenrelic, self.Folder)
            self.Relics:AddItem(tonumber(hiddenrelic), newHiddenRelic)
            newHiddenRelic:Obtain()
            continue
      end
      
      --If exists, destroy and UnObtain
      if hiddenRelicObject ~= nil then
         hiddenRelicObject:UnObtain()
         hiddenRelicObject:Destroy()
      end
   end
   
   if 
   --Fragment is owned by player
      FFDataService:MatchFromSet(
         "Collectibles", self.Folder.Contents:GetAttribute("Fragment")
      )
      
      and
      --Fragment not visually obtained
      self.Folder.Fragment.ImageColor == Color3.new(0,0,0)
      
   then
      --Quick tween the fragment in
      EngineTools.QuickTween(self.Folder.Fragment, 0.2, {ImageColor = Color3.new(255,255,255)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   end
   
   if
   --Fragment is not owned by player
      FFDataService:MatchFromSet(
         "Collectibles", self.Folder.Contents:GetAttribute("Fragment")
      ) ~= true
      
      and
      --Fragment is visually obtained
      self.Folder.Fragment.ImageColor == Color3.new(255,255,255)
      
   then
      EngineTools.QuickTween(self.Folder.Fragment, 0.2, {ImageColor = Color3.new(0,0,0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   end
   
   warn("Don't forget to set the attribute Fragments to Fragment")
   
   --Create an array that stores the shard values
   self.Shards = EngineTools.CSVToArray(self.Folder.Contents:GetAttribute("Shards"))
   
   self.ObtainedShards = FFDataService:MatchFromSet("Collectibles", self.Folder.Contents:GetAttribute("Shards"))
   
   return
end

--CONSTRUCTORS

--[[new:
Create a new collection set from an existing defined folder
@param{Folder} CollectionSetFolder - Folder of the set
]]
function CollectionSet.new(CollectionSetFolder)
   local newCollectionSet = {}
   setmetatable(newCollectionSet, CollectionSet)
   
   newCollectionSet.Instance = CollectionSetFolder
   newCollectionSet.Shards = newCollectionSet.Folder.Contents:GetAttribute("Shards")
   
   newCollectionSet.Relics = OrderedList.new("Ascending")
   
   newCollectionSet.Collectibles = {}

   return newCollectionSet
end

return CollectionSet