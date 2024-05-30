local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Engine = {}

local Bumble = script.Parent

Engine.__index = Engine

Engine.Version = Bumble:GetAttribute("Version")

--Use a custom index to make roblox services easier to reach
local Rbx = setmetatable({}, {__index = function(_, g) return game:GetService(g) end})

--Assign Engine references to global variable.
--[[NOTICE: As of version 3, these are deprecated for normal use. However, they can be
useful in testing or in lazy scripts, so they will continue to exist with the purpose of holding
a direct reference to the recursively required modules.
]]
--[[NOTICE: Nothing should ever try to fetch _G.Engine before this is run. In my use case,
this will not happen as this module literally loads everything and thus must exist first.]]
_G.Engine = Engine
_G.Bumble = Bumble
_G.RobloxServices = Rbx

--Get engine classes. Must be done manually, as delimiters cannot be assigned recursively
--without breaking documentation.

Engine.Version = Bumble:GetAttribute("Version")

Engine.Resources = Bumble.Resources

Engine.Services = setmetatable({}, {
	__index = function(tableInput, keyInput)
		local output
		local status, message = pcall(function()
			output = require(EngineTools.Find(Bumble.Services, keyInput))
			tableInput[keyInput] = output
		end)
		if status == false then
			warn("Critical Error! Failed to initialize " .. keyInput .. "!")
			warn(message)
			return nil
		end
		return tableInput[keyInput]
	end
})
Engine.Classes = setmetatable({}, {
	__index = function(tableInput, keyInput)
		local output
		local status, message = pcall(function()
			output = require(EngineTools.Find(Bumble.Classes, keyInput))
			tableInput[keyInput] = output
		end)
		if status == false then
			warn("Critical Error! Failed to initialize " .. keyInput .. "!")
			warn(message)
			return nil
		end
		return tableInput[keyInput]
	end
})

--ENGINE METHODS-------------------------------------------------------
--Primary methods necessary to use the engine.

--[[GetResource
Return a resource instance from the Bumble Engine's Resources.
 {Engine}
@param {string} resourceName - The name of the resource to look up.

@return {instance} resource - The resultant resource.
]]
function Engine:GetResource(resourceName)
	local Resource

	Resource = EngineTools.Find(Bumble.Resources, resourceName)
	if not Resource then
		print ("Resource search failed.")
	end
	
	return Resource
end

--[[InitializeServices
Initialize all services of given tag
 {Engine}
@param {string} tagName - Name of the tag to initialize services of
]]
function Engine:InitializeServices(tagName)
	local tagged = CollectionService:GetTagged(tagName)
	for _, module in ipairs(tagged) do
		--Wrap in a new thread in case of waitforchild, etc.
		coroutine.wrap(function()
			Engine.Services[module.Name] = require(module)
		end)()
		Engine.ServicesInitialized = true
	end
	return
end

--[[InitializeClasses
Initialize all services of given tag
 {Engine}
@param {string} tagName - Name of the tag to initialize services of
]]
function Engine:InitializeClasses(tagName)
	local tagged = CollectionService:GetTagged(tagName)
	for _, module in ipairs(tagged) do
		--Wrap in a new thread in case of waitforchild, etc.
		coroutine.wrap(function()
			Engine.Classes[module.Name] = require(module)
		end)()
		Engine.ClassesInitialized = true
	end
	return
end

--Engine initialization message.
if Bumble:GetAttribute("StartupMessage") == true then
	--repeat task.wait(.1) until Engine.ServicesInitialized == true
	--repeat task.wait(.1) until Engine.ClassesInitialized == true
	Engine.Initialized = true
	print("🐝 Engine V" .. Engine.Version .. " Is now running successfully!")
end

return Engine