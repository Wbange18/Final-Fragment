local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Get Services and Classes
local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)
local MechanicTags = require(ReplicatedStorage["Bumble Engine"].Resources.Lists.MechanicTags)
local FFDataService = require(ReplicatedStorage["Bumble Engine"].Services.FFDataService)

--Get Resources
local DisabledMechanicsFolder = Engine:GetResource("Disabled Mechanics")
local MechanicService = {}

MechanicService.Mechanics = {}

--METHODS==============================================================

--[[StartAllMechanics
Start all mechanics in the game for the client.

]]
function MechanicService:StartAllMechanics()
	--Iterate through all tags for mechanics, and create them all using this service.
	for _, tag in ipairs(MechanicTags) do
		local tagged = CollectionService:GetTagged(tag)
		for _, instance in ipairs(tagged) do
			MechanicService:CreateMechanic(instance)
		end
	end
	return
end

--[[CreateMechanic
Create an individual mechanic.

@param {instance} Mechanic - Existing mechanic object to create.
]]
function MechanicService:CreateMechanic(Mechanic)
local MechanicState = MechanicService:CheckData(Mechanic)
	local NewMechanic = false
	local MechanicObject = nil
	local ID
	local MechanicName = CollectionService:GetTags(Mechanic)[1]
	--If the mechanic has never been created before, flag it as new.
	if Mechanic:GetAttribute("ID") == nil then
		NewMechanic = true
	end
	
	--Set the ID, or fetch the current one.
	ID = MechanicService:SetID(Mechanic)
	
	--If the mechanic has never been created before, create a new instance. Elsewise, get the mechanic object.
	if NewMechanic then
		MechanicObject = Engine.Classes[MechanicName].new(Mechanic)
		MechanicService.Mechanics[ID] = MechanicObject
	else
		MechanicObject = MechanicService.Mechanics[ID]
	end
	
	if Mechanic.Parent ~= DisabledMechanicsFolder then
		MechanicObject.ActiveLocation = Mechanic.Parent
	end
	
	--If the mechanic data is not verified, destroy the mechanic.
	if MechanicState == false then
		MechanicService:DestroyMechanic(Mechanic)
		return
	end
	
	Mechanic.Parent = MechanicObject.ActiveLocation
	
	--All checks cleared. Run the code written into the mechanic to get it going.
	if Mechanic:HasTag("Not Mechanic") ~= true then
		MechanicObject:Run()
	end

	return
end

--[[DestroyMechanic
Destroy an individual mechanic.

@param {object} Mechanic - Existing mechanic object to destroy.
]]
function MechanicService:DestroyMechanic(Mechanic)
	local ID = MechanicService:SetID(Mechanic)
	
	local MechanicObject = MechanicService.Mechanics[ID]
	
	if Mechanic:HasTag("Not Mechanic") ~= true then
		MechanicObject:Yield()
	end
	
	Mechanic.Parent = DisabledMechanicsFolder
	
	
	return
		
end


--[[ToggleMechanic
Toggle the state of an existing mechanic.

@param {object} Mechanic - The mechanic to toggle.
@param {bool} State - The state.
]]
function MechanicService:ToggleMechanic(Mechanic, State)
	
	if State == "Yield" then
		MechanicService.Mechanics[Mechanic:GetAttribute("ID")]:Yield()
	end
	
	if State == "Run" then
		MechanicService.Mechanics[Mechanic:GetAttribute("ID")]:Run()
	end
end

--[[SetID
Set a mechanic object's ID

@param {object} Mechanic - The mechanic to ID, if not already identified.
]]
function MechanicService:SetID(Mechanic)
	local ID = Mechanic:GetAttribute("ID")
	
	if ID ~= nil then
		return ID
	end
	
	Mechanic:SetAttribute("ID", EngineTools:GenerateID(4))
	
	ID = Mechanic:GetAttribute("ID")
	
	return ID
end

--[[CheckData
Check the data within the mechanic, if any.

@param {object} Mechanic - The mechanic to check.
]]
function MechanicService:CheckData(Mechanic)
	local DataVerified = true
	local PositiveData = {}
	local NegativeData = {}
	
	if Mechanic:GetAttribute("PositiveData") ~= nil then
		PositiveData = EngineTools:CSVToArray(Mechanic:GetAttribute("PositiveData"))
	end
	if Mechanic:GetAttribute("NegativeData") ~= nil then
		NegativeData = EngineTools:CSVToArray(Mechanic:GetAttribute("NegativeData"))
	end
	
	if PositiveData[1] ~= "" and PositiveData[1] ~= nil then
		for _, Data in ipairs(PositiveData) do
			DataVerified = FFDataService:MatchFromSet("GameFlags", Data)
		end
	end
	
	if NegativeData[1] ~= "" and NegativeData[1] ~= nil then
		for _, Data in ipairs(NegativeData) do
			DataVerified = not FFDataService:MatchFromSet("GameFlags", Data)
		end
	end
	
	return DataVerified
end

--SERVICE==============================================================

--Each time the data updates, start all mechanics (omits already running mechanics, etc.)
MechanicService.DataConnection = 
	FFDataService.DataRemote.OnClientEvent:Connect(function()
		if workspace.Camera:FindFirstChild("Local Mechanics") == nil then
			warn("Local Mechanics Folder not found!")
			return
		end
		MechanicService:StartAllMechanics()
	end)

--BELOW SHOULD BE DEPRECATED AS OF V3.0; LEFT FOR UNCERTAINTY
--Tabulate child modules. This also requires them, and thus they are initially called
--and defined here.
--for _, module in ipairs(Bumble.Classes.Mechanics[
--	"World " .. Bumble:GetAttribute("World") .. " Mechanics"
--	]:GetChildren()) do
--	if module:IsA("ModuleScript") and module:GetAttribute("Inactive") == nil then
--		WorldMechanicClasses[module.Name] = require(module)
--	end
--end

return MechanicService