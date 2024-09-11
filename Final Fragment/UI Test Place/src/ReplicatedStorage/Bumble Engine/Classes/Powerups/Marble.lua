local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)
local AccessoryService = require(ReplicatedStorage["Bumble Engine"].Services.AccessoryService)
local Marble = {}

Marble.__index = Marble
setmetatable(Marble, Marble)

Marble.incompatibility = {}

Marble.Accessories = {}

function Marble:Run()
	if self.Running == true then
		return
	end
	self.Running = true
	workspace.CurrentCamera.CameraSubject = self.Handle
	self.Player.Character.Humanoid:ChangeState("Physics")
	

	self.Player.Character.HumanoidRootPart.Running.Volume = 0
	self.Player.Character.Humanoid.WalkSpeed = 0
	self.Animation = EngineTools:QuickAnimation(self.Handle.Animation)
	self.Animation:AdjustSpeed(0)
	EngineTools:QuickTween(self.Handle, .5, {Size = self.Size})
	EngineTools:QuickTween(self.Detail, .5, {Size = self.DetailSize, Transparency = 1})
	local steppedConnection
	local steppedOperations = {
		[true] = function()
			self.Force.Force = self.Player.Character.Humanoid.MoveDirection * 
				(self.Speed * self.Player.Character.Humanoid.MoveDirection.Magnitude)
		end,
		[false] = function()
			steppedConnection:Disconnect()
		end,
	}
	steppedConnection = RunService.Stepped:Connect(function()
		steppedOperations[self.Running]()
	end)
	task.wait(1)
	self.Emitter.Enabled = false
end

function Marble:Yield()
	if self.Running == false then
		return
	end
	self.Running = false
	self.Player.Character.Humanoid:SetStateEnabled("Physics", false)
	self.Player.Character.Humanoid:ChangeState("Running")
	self.Player.Character.HumanoidRootPart.Running.Volume = 0.65
	self.Animation:Stop()
	
	self.Handle.CanCollide = false
	EngineTools:QuickTween(self.Detail, .5, {Size = Vector3.new(.1,.1,.1), Transparency = 0})
	EngineTools:QuickTween(self.Handle, .5, {Size = Vector3.new(.1,.1,.1)}).Completed:Wait()
	
	self.Accessory:Destroy()
	workspace.CurrentCamera.CameraSubject = self.Player.Character.Head
	self.Player.Character.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
	self.Destroyed = true
end

function Marble.new()
	local newMarble = {}
	setmetatable(newMarble, Marble)
	
	newMarble.Player = EngineTools:GetPlayer()
	
	local MarbleAccessory = Engine:GetResource("Marble")
	
	local Parts = {}
	
	for _, part in newMarble.Player.Character:GetChildren() do
		if part:IsA("BasePart") then
			table.insert(Parts, part)
		end
	end
	
	local CenterOfMass = EngineTools:GetCenterOfMass(Parts)
	
	MarbleAccessory.Handle.RootAttachment.Position = 
		newMarble.Player.Character.HumanoidRootPart.Position - CenterOfMass
	newMarble.Accessory = AccessoryService:AddAccessory(MarbleAccessory)
	newMarble.Accessory.Handle.CanCollide = true
	newMarble.Handle = newMarble.Accessory.Handle
	newMarble.Detail = newMarble.Handle.Detail
	newMarble.Emitter = newMarble.Detail.ParticleEmitter
	newMarble.Force = newMarble.Handle.VectorForce
	newMarble.Speed = newMarble.Accessory:GetAttribute("MarbleSpeed")
	newMarble.Size = newMarble.Accessory:GetAttribute("MarbleSize")
	newMarble.DetailSize = newMarble.Accessory:GetAttribute("DetailSize")
	newMarble.Running = false
	newMarble.Destroyed = false
	
	return newMarble
end

return Marble