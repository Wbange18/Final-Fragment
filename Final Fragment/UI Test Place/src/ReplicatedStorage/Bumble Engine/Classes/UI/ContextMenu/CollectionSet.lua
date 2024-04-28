local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Collectible = require(ReplicatedStorage["Bumble Engine"].Classes.UI.ContextMenu.Collectible)
local FFDataService = require(ReplicatedStorage["Bumble Engine"].Services.FFDataService)
local CollectionSet = {}

CollectionSet.__index = CollectionSet

--METHODS

--[[Show
Show the collection set
]]
function CollectionSet:Show()
   for i, relic in ipairs(self.Relics) do
      if FFDataService:MatchFromSet("Relics", relic.Value) == true then
         
      end
   end
   return
end

--[[Hide
Hide the collection set
]]
function CollectionSet:Hide()
   
   return
end

--[[Update
Update the set in case anything changed
]]
function CollectionSet:Update()
   
   return
end

--CONSTRUCTORS

--[[new
Create a new collection set from an existing defined folder
@param{Folder} CollectionSetFolder - Folder of the set
]]
function CollectionSet.new(CollectionSetFolder: Folder)
   local newCollectionSet = {}
   setmetatable(newCollectionSet, CollectionSet)
   
   newCollectionSet.Folder = CollectionSetFolder
   newCollectionSet.Relics = {}
   
   newCollectionSet.Collectibles = {}
   local RelicValues = EngineTools:CSVToArray(newCollectionSet.Folder.Contents:GetAttribute("Relics"))
   
   for i, relic in ipairs(RelicValues) do
      
      --Preliminary check to see if the relic is hidden
      if string.match(
         newCollectionSet.Folder.Contents:GetAttribute("HiddenRelics"), relic
      ) ~= nil then
         
         --If it is a hidden relic, check if the player has obtained it
         if FFDataService:MatchFromSet("Relics", relic) ~= true then
            continue
         end
      end
      
      table.insert(newCollectionSet.Relics, Collectible.new(relic, CollectionSetFolder))
   end
   
   newCollectionSet.Shards = EngineTools:CSVToArray(newCollectionSet.Folder.Contents:GetAttribute("Shards"))
   
   --[[Stopping here. Current train of thought:
   I need to instantiate the UI with the information from the collection set. Should the Frame do that...?
   ]]
   
   return newCollectionSet
end

return CollectionSet