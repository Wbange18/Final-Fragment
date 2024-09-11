local Metadata = {}
Metadata.__index = function(table, key)
   rawset(table, key, "N/A")
   return rawget(table, key)
end

--Structure which defines specific properties about every collectible in FF.
local CollectibleMetadata = {}

--Allow nil requests, throwing a warning when this occurs.
CollectibleMetadata.__index = function(table, key)
   if rawget(table, key) == nil then
      --Initialize the collectible with an empty table and Metadata metatable.
      rawset(table, key, setmetatable({}, Metadata))
   end
   rawset(table, key, setmetatable({}, Metadata))
   
   return rawget(table, key)
end

CollectibleMetadata.__newindex = function(table, key, value)
   rawset(table, key, value)
end

--Shorthand the list and module
CM = CollectibleMetadata

setmetatable(CM, CollectibleMetadata)

return CM