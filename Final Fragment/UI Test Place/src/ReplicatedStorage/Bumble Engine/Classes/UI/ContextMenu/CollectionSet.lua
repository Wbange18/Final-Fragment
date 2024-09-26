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
      
      --THIS MIGHT BE A BAD IDEA BUT IT ALSO
      --MIGHT LOOK REALLY COOL
      task.wait()
      
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
      --Disconnect all the mouse hover events.
      if relic.connection ~= nil then
         relic.connection:Disconnect()
      end
      
      --If first parameter is blank, this uses internal centerposition value
      relic:Move(nil, Enum.EasingDirection.In)
      relic:Hide()
      
      --I tried to keep the lines below, but it detatches all references and breaks stuff
      --This seems to actually severely impact performance. Turns out deleting and cloning 16 objects is kind of a problem. big surprise.
      
      --self.Relics:Wipe()
      
      --Multithread to avoid delay
      --coroutine.wrap(function()
         
         --Time the prior two functions take to complete.
         --task.wait(0.25)
         
         --Since self:Update() can create relics, we can destroy them to save memory.
         --relic:Destroy()
      --end)()
      
      --THIS MIGHT BE A BAD IDEA BUT IT ALSO
      --MIGHT LOOK REALLY COOL
      task.wait()
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
   
   --Coroutines which request data calls from the server. Check these first

   --Check Primary collectible
   coroutine.wrap(function()
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
   end)()
   
   --Check Shards
   coroutine.wrap(function()
      self.ObtainedShards = FFDataService:MatchDataTable("Collectibles", EngineTools:CSVToArray(WorldContexts[self.WorldID].Shards))
   end)()
   
   local function NewHide(relic)
      local newRelic = Collectible.new(relic)
      newRelic.Instance.Parent = self.Instance.Relics
      self.Relics:AddItem(string.match(relic, "%d+"), newRelic)
      newRelic:UnObtain()
      return
   end
   
   local function NewShow(relic)
      local newRelic = Collectible.new(relic)
      newRelic.Instance.Parent = self.Instance.Relics
      self.Relics:AddItem(string.match(relic, "%d+"), newRelic)
      newRelic:Obtain()
      return
   end
   
   local function ExistingHide(relic)
      local existingRelic = self.Relics:GetItemByValue(string.match(relic, "%d+"))
      existingRelic:UnObtain()
      return
   end
   
   local function ExistingShow(relic)
      local existingRelic = self.Relics:GetItemByValue(string.match(relic, "%d+"))
      existingRelic:Obtain()
      return
   end
   
   local function Remove(relic)
      local hiddenRelicObject = self.Relics:GetItemByValue(string.match(relic, "%d+"))
      hiddenRelicObject:UnObtain()
      hiddenRelicObject:Destroy()
      return
   end

   local function DoNothing(relic)
      return
   end
   
   --First state: If exists, second state: if obtained
   local UpdatesTable = {
      [0] = {
         [0] = NewHide,
         [1] = NewShow
      },
      [1] = {
         [0] = ExistingHide,
         [1] = ExistingShow
      }
   }

   --First state: If exists, second state: if obtained
   local HiddenUpdatesTable = {
      [0] = {
         [0] = DoNothing,
         [1] = NewShow
      },
      [1] = {
         [0] = Remove,
         [1] = DoNothing
      }
   }
   
   --Cases where a relic is present do not give us a value of true
   
   for i, relic in self.RelicValues do
      UpdatesTable[
         EngineTools:BoolToNumber(not not self.Relics:GetItemByValue(relic))
      ][
         EngineTools:BoolToNumber(FFDataService:MatchFromSet("Collectibles", relic))
      ](relic)
   end
   
   for i, relic in self.HiddenRelicValues do
      HiddenUpdatesTable[
         EngineTools:BoolToNumber(not not self.Relics:GetItemByValue(relic))
      ][
         EngineTools:BoolToNumber(FFDataService:MatchFromSet("Collectibles", relic))
      ](relic)
   end
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
   
   newCollectionSet.RelicValues = EngineTools:CSVToArray(WorldContexts[newCollectionSet.WorldID].Relics)
   newCollectionSet.HiddenRelicValues = EngineTools:CSVToArray(WorldContexts[newCollectionSet.WorldID].HiddenRelics)
   
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