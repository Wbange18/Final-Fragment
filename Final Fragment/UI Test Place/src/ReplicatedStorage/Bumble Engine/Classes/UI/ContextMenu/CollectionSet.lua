local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedList = require(ReplicatedStorage["Bumble Engine"].Classes.Data.OrderedList)
local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Collectible = require(ReplicatedStorage["Bumble Engine"].Classes.UI.ContextMenu.Collectible)
local FFDataService = require(ReplicatedStorage["Bumble Engine"].Services.FFDataService)

--[[CollectionSet: Set of Collectible classes and data used to organize data for the ContextFrame class.]]

local CollectionSet = {}

CollectionSet.__index = CollectionSet

--METHODS

--[[Show
Show the collection set
]]
function CollectionSet:Show()
   --TODO: Find appropriate locations for relics in the set. Remember: Polar coordinates
   
   return
end

--[[Hide
Hide the collection set
]]
function CollectionSet:Hide()
   --TODO: Return all to center
   
   return
end

--[[Update
Update the set in case anything changed
]]
function CollectionSet:Update()
      local RelicValues = EngineTools:CSVToArray(self.Folder.Contents:GetAttribute("Relics"))
   
   for i, relic in ipairs(RelicValues) do
      
      --Preliminary check to see if the relic is hidden
      if string.match(
         self.Folder.Contents:GetAttribute("HiddenRelics"), relic
      ) ~= nil then
         
         --If it is a hidden relic, check if the player has obtained it
         if FFDataService:MatchFromSet("Collectibles", relic) ~= true then
            continue
         end
      end
      
      --If the relic is already in the UI, ignore
      if table.find(self.Collectibles, relic) then
         return
      end
      
      --Create a new Collectible object and parent it to the contents config object in the folder
      table.insert(self.Relics, Collectible.new(relic, self.Folder.Contents))
   end
   
   --Create an array that stores the shard values
   self.Shards = EngineTools:CSVToArray(self.Folder.Contents:GetAttribute("Shards"))
   
   self.ObtainedShards = FFDataService:MatchFromSet("Collectibles", self.Folder.Contents:GetAttribute("Shards"))
   return
end

--CONSTRUCTORS

--[[new
Create a new collection set from an existing defined folder
@param{Folder} CollectionSetFolder - Folder of the set
]]
function CollectionSet.new(CollectionSetFolder)
   local self = {}
   setmetatable(self, CollectionSet)
   
   self.Folder = CollectionSetFolder
   self.Shards = self.Folder.Contents:GetAttribute("Shards")
   
   self.Relics = OrderedList.new("Ascending")
   
   self.Collectibles = {}

   return self
end

return CollectionSet