local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedList = require(ReplicatedStorage["Bumble Engine"].Classes.Data.OrderedList)
local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Collectible = require(ReplicatedStorage["Bumble Engine"].Classes.UI.ContextMenu.Collectible)
local CollectibleMetadata = require(ReplicatedStorage["Bumble Engine"].Configuration.CollectibleMetadata)
local WorldContexts = require(ReplicatedStorage["Bumble Engine"].Configuration.WorldContexts)
local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)
local FFDataService = require(ReplicatedStorage["Bumble Engine"].Services.FFDataService)

--Get Resources
local ReferenceSet = Engine:GetResource("Reference Set")

--[[CollectionSet: Set of Collectible classes and data used to organize data for the ContextFrame class.]]

local CollectionSet = {}

CollectionSet.__index = CollectionSet

--METHODS

--[[Show:
Show the collection set
]]
function CollectionSet:Show()
   
   local angleSubdivision, relicAngle, relicX, relicY, relicPosition
   
   for i, relic in self.Relics:GetList() do
      print(self.Relics:GetLength())
      --Get the angle between each piece
      angleSubdivision = (90 - 20) / self.Relics:GetLength()
      
      --Multiply the subdivision by the ordered key of the relic. BUT the list is already ordered.
      --relicAngle = angleSubdivision * self.Relics:GetKey(relic.Value)
      relicAngle = angleSubdivision * i
      
      --Convert polar to x and y, adding the padding to the angle
      relicX = 0.58 * math.cos(math.rad(relicAngle + 10))
      
      --Y axis is flipped because roblox is cool
      relicY = -0.58 * math.sin(math.rad(relicAngle + 10))
      
      relicPosition = UDim2.new(0.5 + relicX, 0,0.5 + relicY, 0)
      
      print(relicAngle, angleSubdivision)
      
      relic:Move(relicPosition)
      relic:Show()
      
      --Recursive function which waits for the mouse to leave, then waits for the mouse to enter.
      local function MouseEnter()
         
         relic:Focus()
         
         relic.Instance.Group.Hitbox.MouseLeave:Once(function()
            
            relic:UnFocus()
            
            --Recurse the function, assigning the connection value.
            relic.connection = relic.Instance.Group.Hitbox.MouseEnter:Once(MouseEnter)
         end)
      end
      
      --Run MouseEnter once when the mouse enters the frame.
      relic.EnterConnection = relic.Instance.Group.Hitbox.MouseEnter:Once(MouseEnter)
      
   end
   
   --Add the preview
   EngineTools:QuickTween(self.Instance.Preview, .25, {ImageTransparency = 0}, nil, Enum.EasingDirection.Out)
   return
end

--[[Hide:
Hide the collection set
]]
function CollectionSet:Hide()
   
   for i, relic in ipairs(self.Relics:GetList()) do
      print(relic)
      --Disconnect all the mouse hover events.
      if relic.connection ~= nil then
         relic.connection:Disconnect()
      end
      
      --If first parameter is blank, this uses internal centerposition value
      relic:Move(nil, Enum.EasingDirection.In)
      relic:Hide()
      
      --I tried to keep the lines below, but it detatches all references and breaks stuff
      
      --self.Relics:Wipe()
      
      --Multithread to avoid delay
      --coroutine.wrap(function()
         
         --Time the prior two functions take to complete.
         --task.wait(0.25)
         
         --Since self:Update() can create relics, we can destroy them to save memory.
         --relic:Destroy()
      --end)()
   end
   
   --Remove the preview
   EngineTools:QuickTween(self.Instance.Preview, .25, {ImageTransparency = 1}, nil, Enum.EasingDirection.In)
   
   return
end

--[[Update:
Update the set in case anything changed, checking if hidden relics are found, and unfading
obtained relics.
]]
function CollectionSet:Update()
   --local RelicValues = EngineTools:CSVToArray(self.Folder.Contents:GetAttribute("Relics"))
   local RelicValues = EngineTools:CSVToArray(WorldContexts[self.WorldID].Relics)
   
   --local HiddenRelicValues = EngineTools:CSVToArray(self.Folder.Contents:GetAttribute("HiddenRelics"))
   local HiddenRelicValues = EngineTools:CSVToArray(WorldContexts[self.WorldID].HiddenRelics)
   
   for i, relic in RelicValues do
      
      --This doesnt make sense. why get the key if im matching value>?
      --if self.Relics:GetItemByValue(string.match(relic, "%d+")) == nil then
         
      
      --Check if the relic exists in the ordered list
      if self.Relics:GetItemByValue(relic) == nil then
         
         --Create the new collectible and add it to ordered list by relic number
         local newRelic = Collectible.new(relic)
         
         newRelic.Instance.Parent = self.Instance.Relics
         
         self.Relics:AddItem(string.match(relic, "%d+"), newRelic)
         
         if FFDataService:MatchFromSet("Collectibles", relic) then
            newRelic:Obtain()
            continue
         end
         
         newRelic:UnObtain()
         continue
      end
      
      local existingRelic = self.Relics:GetItemByValue(string.match(relic, "%d+"))
      
      if FFDataService:MatchFromSet("Collectibles", relic) then
         existingRelic:Obtain()
         continue
      end
      existingRelic:UnObtain()
      continue
   end
   
   for i, hiddenrelic in ipairs(HiddenRelicValues) do
      local hiddenRelicObject = self.Relics:GetItemByValue(string.match(hiddenrelic, "%d+"))
      if hiddenRelicObject == nil and FFDataService:MatchFromSet("Collectibles", hiddenrelic) then
            local newHiddenRelic = Collectible.new(hiddenrelic)
            newHiddenRelic.Instace.Parent = self.Instance.Relics
            self.Relics:AddItem(string.match(hiddenrelic, "%d+"), newHiddenRelic)
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
   --Primary is owned by player
      FFDataService:MatchFromSet(
         "Collectibles", self.Primary
      )
      
      and
      --Primary not visually obtained
      self.Instance.Primary.ImageColor == Color3.new(0,0,0)
      
   then
      --Quick tween the Primary in
      EngineTools:QuickTween(self.Instance.Primary, 0.2, {ImageColor = Color3.new(255,255,255)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   end
   
   if
   --Primary is not owned by player
      FFDataService:MatchFromSet(
         "Collectibles", self.Primary
      ) ~= true
      
      and
      --Primary is visually obtained
      self.Instance.Primary.ImageColor3 == Color3.new(255,255,255)
      
   then
      EngineTools:QuickTween(self.Instance.Primary, 0.2, {ImageColor = Color3.new(0,0,0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
   end
   
   --self.ObtainedShards = FFDataService:MatchFromSet("Collectibles", self.Folder.Contents:GetAttribute("Shards"))
   
   --self.ObtainedShards = FFDataService:MatchFromSet("Collectibles", WorldContexts[self.WorldID].Shards)
   
   self.ObtainedShards = FFDataService:MatchDataTable("Collectibles", EngineTools:CSVToArray(WorldContexts[self.WorldID].Shards))
   
   print(self.ObtainedShards)
   
   return
end

--CONSTRUCTORS

--[[new:
Create a new collection set from an existing defined folder
@param{number} ID - Identifier for the world context set
]]
function CollectionSet.new(ID)
   local newCollectionSet = {}
   setmetatable(newCollectionSet, CollectionSet)
   
   newCollectionSet.WorldID = ID
   
   newCollectionSet.Instance = ReferenceSet:Clone()
   
   newCollectionSet.Instance.Preview.Image = WorldContexts[ID].Preview

   --Handled by context frame
   --newCollectionSet.Instance.TextLabel.Text = WorldContexts[ID].Name
   
   newCollectionSet.Relics = OrderedList.new("Ascending")
   
   newCollectionSet.Shards = EngineTools:CSVToArray(WorldContexts[ID].Shards)
   
   newCollectionSet.Primary = WorldContexts[ID].Primary
   
   --If there is a primary, set the image
   if newCollectionSet.Primary ~= "" then
      newCollectionSet.Instance.Primary.Image
       = CollectibleMetadata[newCollectionSet.Primary].imageAsset
   end
   
   --This causes weird issue so I temporarily kill :O
   newCollectionSet:Update()
   
   --TODO: CONTINUE FROM HERE
   --NOTES ON SEP 15 AT 6 PM: Collectibles seem to be done along with the frame. Just need to iterate and boot things up here! The end!
   
   return newCollectionSet
end

return CollectionSet