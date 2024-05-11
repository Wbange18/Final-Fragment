local Collectible = {}
Collectible.__index = function(table, key)
   rawset(table, "N/A")
end

Collectible.__newindex = function(table, key, value)
   
end

--Structure which defines specific properties about every collectible in FF.
local CollectibleDataList = {}

--Allow nil requests, throwing a warning when this occurs.
CollectibleDataList.__index = function(table, key)
   
   rawset(table, key, )
   
   return rawget(table, key)
end

--Shorthand the list and module
CDL = CollectibleDataList

--Assign all special collectibles below-----------------------------------------

--[[DOCUMENTATION:
specialType - Specific type of collectible. For example, shard S1 could be of type "Jagged"
specialName - Specific name for collectible. Generically usable, maybe relic R1 is "Battery"
levelName - Level name, specifically used for relics and fragments.
imageAsset - Image asset, specifically for relics and fragments.
]]

--FRAGMENTS---------------------------------------------------------

CDL.F1.imageAsset = "rbxassetid://6343674936"
CDL.F2.imageAsset = "rbxassetid://6343674883"
CDL.F3.imageAsset = "rbxassetid://6343674817"
CDL.F4.imageAsset = "rbxassetid://6343674767"
CDL.F5.imageAsset = "rbxassetid://6343674705"
CDL.F6.imageAsset = "rbxassetid://6343674664"
CDL.F7.imageAsset = "rbxassetid://6343674604"
CDL.F8.imageAsset = "rbxassetid://6343674539"
CDL.F9.imageAsset = "rbxassetid://6343674485"









CDL.F1




















--Note: F10 doesn't need an image, as this won't be revealed.

--RELICS-------------------------------------------------------------

CDL.R1.levelName = "Error Terror"
CDL.R2.levelName = "Sunken Tracks"
CDL.R3.levelName = "Shattered Settlement"
CDL.R4.levelName = "Cave In! -Deprecated"
CDL.R5.levelName = ""

--SHARDS------------------------------------------------------------


return CollectibleDataList