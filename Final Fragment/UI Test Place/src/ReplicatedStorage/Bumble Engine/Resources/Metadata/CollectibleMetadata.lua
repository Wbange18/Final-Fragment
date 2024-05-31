local Metadata = {}
Metadata.__index = function(table, key)
   rawset(table, key, "N/A")
   return rawget(table, key)
end

--Structure which defines specific properties about every collectible in FF.
local CollectibleMetadata = {}

--Allow nil requests, throwing a warning when this occurs.
CollectibleMetadata.__index = function(table, key)
   
   --Index the value as a blank table with the Collectible metatable. In other words, every member found from CDL will be an empty table of metatable Collectible.
   rawset(table, key, setmetatable({}, Metadata))
   
   return rawget(table, key)
end

--Shorthand the list and module
CM = CollectibleMetadata

--Assign all special collectibles below-----------------------------------------

--[[DOCUMENTATION:
specialType - Specific type of collectible. For example, shard S1 could be of type "Jagged"
specialName - Specific name for collectible. Generically usable, maybe relic R1 is "Battery"
levelName - Level name, specifically used for relics and fragments.
imageAsset - Image asset, specifically for relics and fragments.
]]

--FRAGMENTS---------------------------------------------------------

CM.F1.imageAsset = "rbxassetid://6343674936"
CM.F2.imageAsset = "rbxassetid://6343674883"
CM.F3.imageAsset = "rbxassetid://6343674817"
CM.F4.imageAsset = "rbxassetid://6343674767"
CM.F5.imageAsset = "rbxassetid://6343674705"
CM.F6.imageAsset = "rbxassetid://6343674664"
CM.F7.imageAsset = "rbxassetid://6343674604"
CM.F8.imageAsset = "rbxassetid://6343674539"
CM.F9.imageAsset = "rbxassetid://6343674485"


--Note: F10 doesn't need an image, as this won't be revealed.

--RELICS-------------------------------------------------------------

CM.R1.levelName = "Error Terror"
CM.R2.levelName = "Sunken Tracks"
CM.R3.levelName = "Shattered Settlement"
CM.R4.levelName = "Cave In! -Deprecated"
CM.R5.levelName = ""
CM.R1.imageAsset = "http:/whatever.fortnite"
--SHARDS------------------------------------------------------------


return CollectibleMetadata