local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Beamer = {}

Beamer.__index = Beamer
setmetatable(Beamer, Beamer)

Beamer.Running = false

function Beamer:Run()
	if self.Running == true then
		return
	end
	self.Running = true
	self.Coroutine = coroutine.wrap(function()
		task.wait(self.TimeOffset)
		while self.Running do
			self.Hinge.TargetAngle = self.StartAngle
			self.Hinge.AngularSpeed = self.AngularSpeed
			local BeamTween = EngineTools.QuickTween(
				self.BeamAttachment2, .5, {Position = Vector3.new(-self.Length,0,0)}, 
				Enum.EasingStyle.Quint, Enum.EasingDirection.Out
			)
			coroutine.wrap(function()
				local raycastParams = RaycastParams.new()
				raycastParams.CollisionGroup = "TouchParts"
				raycastParams.IgnoreWater = true
				self.Killing = true
				while self.Killing do
					local Raycast = workspace:Raycast(
						self.BeamAttachment1.WorldPosition, self.BeamAttachment2.WorldPosition - 
							self.BeamAttachment1.WorldPosition, raycastParams)
					if Raycast then
						self.Player.Character.Humanoid.Health = 0
					end
					task.wait(.02)
				end
			end)()			
			BeamTween.Completed:Wait()
			self.Hinge.TargetAngle = self.EndAngle
			task.wait(self.RotateTime)
			BeamTween = EngineTools.QuickTween(
				self.BeamAttachment2, .5, {Position = Vector3.new(0,0,0)}, 
				Enum.EasingStyle.Quint, Enum.EasingDirection.In
			)
			BeamTween.Completed:Wait()
			self.Killing = false
			self.Hinge.AngularSpeed = 10
			self.Hinge.TargetAngle = self.StartAngle
			task.wait(self.WaitTime)
		end
	end)()
end

function Beamer:Yield()
	if self.Running == false then
		return
	end
	self.Running = false
end

function Beamer.new(model)
	local newBeamer = {}
	setmetatable(newBeamer, Beamer)
	
	newBeamer.Instance = model
	newBeamer.Player = game.Players.LocalPlayer
	newBeamer.Character = newBeamer.Player.Character
	newBeamer.TimeOffset = newBeamer.Instance:GetAttribute("TimeOffset")
	newBeamer.RotateTime = newBeamer.Instance:GetAttribute("RotateTime")
	newBeamer.AngularSpeed = newBeamer.Instance:GetAttribute("AngularSpeed")
	newBeamer.WaitTime = newBeamer.Instance:GetAttribute("WaitTime")
	newBeamer.Length = newBeamer.Instance.Range.Size.Z
	newBeamer.StartAngle = newBeamer.Instance.StartAngle.Orientation.Y - 90
	newBeamer.EndAngle = newBeamer.Instance.EndAngle.Orientation.Y - 90
	newBeamer.Hinge = newBeamer.Instance.MainHinge.HingeConstraint
	newBeamer.Killing = false
	newBeamer.BeamAttachment1 = newBeamer.Instance.Beamer[1]
	newBeamer.BeamAttachment2 = newBeamer.Instance.Beamer[2]
	
	newBeamer.Instance.StartAngle:Destroy()
	newBeamer.Instance.EndAngle:Destroy()
	newBeamer.Instance.Range:Destroy()
	return newBeamer
end


return Beamer