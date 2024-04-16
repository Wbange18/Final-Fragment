local tweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local ring1 = script.Parent.InnerRing
local ring2 = script.Parent.OuterRing
local humanoid = Player.Character:WaitForChild("Humanoid")
local lastPosition = Player.Character.HumanoidRootPart.Position

local ExtraSpeedValue = script.Parent.AdditionalSpeed

local speedAdditive = 0
local defaultSpeed = 0.5
local tweenWaitTime = .05

local info = TweenInfo.new(tweenWaitTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

local directionTable = {
	["Backwards"] = -1,
	["Forwards"] = 1
}

local function createTween(item, direction)
	--Calculate the new rotation by adding the speedAdditive, multiply by direction
	local newRotation = item.Rotation + ((defaultSpeed + speedAdditive) * directionTable[direction])
	
	local Tween = tweenService:Create(item, info, {Rotation = newRotation})
	Tween:Play()
	Tween.Completed:Wait()
end

local function rotateFunction()	
	while script.Parent ~= nil do
		local dead = false
		coroutine.wrap(function()
			while script.parent ~= nil and dead == false do

				--Get a vector of displacement from last position to current
				local displacementVector = Player.Character.HumanoidRootPart.Position -
					lastPosition

				local displacementMagnitude = displacementVector.magnitude

				--Determine what to add to the spin speed, clamped to stop high speed
				speedAdditive = math.clamp(displacementMagnitude / 2, 0, 7) + ExtraSpeedValue.Value

				--Record last position after determining speed
				lastPosition = Player.Character.HumanoidRootPart.Position

				--Tween Creation & Play
				coroutine.wrap(createTween)(ring1, "Forwards")
				coroutine.wrap(createTween)(ring2, "Backwards")
				task.wait(tweenWaitTime)
			end
		end)()

		Player.Character.Humanoid.Died:Wait()
		Player.CharacterAdded:Wait()
		Player.Character:WaitForChild("HumanoidRootPart")
		dead = true
	end
	

	
	
end

rotateFunction()