-- Define defaults for each type of collectible.
local FragmentDefaults = {
   specialType = "",
   specialName = "",
   levelName = "",
   imageAsset = "rbxassetid://6343674936"  -- Default image asset for fragments.
}

local RelicDefaults = {
   specialType = "",
   specialName = "",
   levelName = "UNKNOWN",
   imageAsset = "rbxassetid://12358680051"
}

local ShardDefaults = {
   specialType = "",
   specialName = "",
   levelName = "",
   imageAsset = "Ploopy"
}

-- Function to apply defaults based on type.
local function getDefaultsForType(type)
   if type == "F" then
      return FragmentDefaults
   elseif type == "R" then
      return RelicDefaults
   elseif type == "S" then
      return ShardDefaults
   else
      return {}  -- Fallback empty defaults.
   end
end

-- Define the metatable that handles undefined keys.
local Metadata = {}
Metadata.__index = function(table, key)
   local type = string.sub(table.__type, 1, 1)  -- Assuming the type is stored in table.__type
   
   -- Get defaults for this type (F, R, S)
   local defaults = getDefaultsForType(type)
   
   if defaults[key] then
      -- Return the default value if the key exists in the defaults table.
      return defaults[key]
   else
      return "N/A"  -- Return "N/A" for undefined keys.
   end
end

-- Define the collectible metadata structure.
local CollectibleMetadata = {}
CollectibleMetadata.__index = function(table, key)
   -- If the key doesn't exist, create a new table for it with the Metadata metatable. Redundant statement for stranger cases.
   if rawget(table, key) == nil then
      local collectibleType = string.sub(key, 1, 1)  -- Example: key = "F1", collectibleType = "F"
      local newCollectible = {__type = collectibleType}
      setmetatable(newCollectible, Metadata)
      rawset(table, key, newCollectible)
   end

   return rawget(table, key)
end

-- Allow assignment of values using __newindex.
CollectibleMetadata.__newindex = function(table, key, value)
   rawset(table, key, value)
end

-- Set the metatable for the main collectible table.
local CM = setmetatable({}, CollectibleMetadata)

return CM