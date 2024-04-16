local Engine = _G.Engine

local AccessoryService = Engine.Services.AccessoryService

local JumpPad = {}

JumpPad.__index = JumpPad
setmetatable(JumpPad, JumpPad)

--PROPERTIES===========================================================

JumpPad.Instance = nil
JumpPad.Pad = nil
JumpPad.Height = nil
JumpPad.Running = false
JumpPad.Debounce = false
JumpPad.Connection = nil
JumpPad.Player = nil
JumpPad.Character = nil
JumpPad.StartPosition = nil

--METHODS==============================================================

--[[Run
Start the mechanic.
@method
]]
function JumpPad:Run()
	if self.Running == true then
		return
	end
	self.Running = true
	self.Connection = self.Pad.Touched:Connect(function(Part)
		if Part == self.Player.Character["Left Leg"] or 
			Part == self.Player.Character["Right Leg"] and 
			self.Debounce == false 
		then
			self:Jump()
		end
	end)
	--Initiate the connection and jump function
end

--[[Yield
Pause the mechanic, and hide it by default.
@method
@param {bool} hide - Whether or not to hide the mechanic while paused. Default is true.
]]
function JumpPad:Yield()
	self.Connection:Disconnect()
	self.Running = false
end

--[[Jump
Launch the character updwards.
]]
function JumpPad:Jump()
	if self.Debounce == true then 
		return
	end
	self.Debounce = true
	
	self.Instance.Top.Position = self.StartPosition
	
	local NewPosition = Vector3.new(
		self.StartPosition.X,
		self.StartPosition.Y + 3,
		self.StartPosition.Z
	)
	
	--Maybe I could make this height based, so the spring flung the pad at greater height goals
	coroutine.wrap(function()
		local Tween1 = Engine.Tools:QuickTween(self.Instance.Top, .25, {Position = NewPosition}, "Quad", "Out")
		Tween1.Completed:Wait()
		local Tween2 = Engine.Tools:QuickTween(self.Instance.Top, .3, {Position = self.StartPosition}, "Sine", "In")
	end)()
	
	local gravity = game.Workspace.Gravity
	local JumpPower = math.sqrt(2*gravity*self.Height)
	self.Player.Character.Humanoid.JumpPower = JumpPower
	self.Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	local trail = AccessoryService:AddAccessory(script.TrailPart)
	
	coroutine.wrap(function()
		local Time = 1 * self.Height / 100
		local Tween = Engine.Tools:QuickTween(trail.Handle.Trail, Time, {Lifetime = 0}, "Sine", "In")
		task.wait(Time)
		AccessoryService:RemoveAccessory(trail)
		self.Debounce = false
		self.Player.Character.Humanoid.JumpPower = game.StarterPlayer.CharacterJumpPower
	end)()
end


--CONSTRUCTORS========================================================

--[[new
Create a Jump Pad
@constructor
@param {object} model - The subject model of the platform.
]]
function JumpPad.new(model)
	local newJumpPad = {}
	setmetatable(newJumpPad, JumpPad)
	
	newJumpPad.Instance = model
	newJumpPad.Pad = newJumpPad.Instance.Pad
	newJumpPad.Height = newJumpPad.Instance.Height.Size.Y
	newJumpPad.StartPosition = newJumpPad.Instance.Top.Position

	newJumpPad.Instance.Height:Destroy()
	
	newJumpPad.Player = game.Players.LocalPlayer
	
	newJumpPad.Character = newJumpPad.Player.Character
	
	--Create blank connection to touched in case it must be disconnected.
	newJumpPad.Connection = newJumpPad.Pad.Touched:Connect(function()
	end)
	
	return newJumpPad
end


return JumpPad