local RunService = game:GetService("RunService")

--Dangerous line, make sure this is loaded on client only.
local Player = game.Players.LocalPlayer

--[[Spinner: Simple class which provides spin animation features for the ContextFrame class.]]

local Spinner = {}

Spinner.__index = Spinner

--METHODS

--[[ChangeSpeed
Change the spinner's speed
@param {number} speed - Speed to add to the spinner.
@param {number} smoothing - Time to smooth the speed over.
]]
function Spinner:ChangeSpeed(speed, smoothing)
   if smoothing ~= nil and smoothing ~= 0 then
      coroutine.wrap(function()
         repeat
            self.extraSpeed += speed/smoothing
            task.wait(.1)
         until self.extraSpeed >= speed
      end)()
      return
   end
   self.extraSpeed = speed
   return
end

--[[ShiftSpeed
Shift the spinner's speed for a short time. Will not respond if a shift is currently occurring
@param {number} speed - Speed to shift to
@param {number} time - Time of the shift
]]
function Spinner:ShiftSpeed(speed, time)
   if self.Shifting then
      return
   end
   self.Shifting = true
   self:ChangeSpeed(speed, time)
   coroutine.wrap(function()
      task.wait(time)
      self:ChangeSpeed(0 - speed, time)
      self.Shifting = false
   end)()
end

--CONSTRUCTOR

--[[new
Create a new spinner object
]]
function Spinner.new()
   local newSpinner = {}
   
   setmetatable(newSpinner, Spinner)
   
   newSpinner.innerRing = Player.PlayerGui["In-Game UI"].ContextMenu.Frame["Ring Spinner"].InnerRing
   newSpinner.outerRing = Player.PlayerGui["In-Game UI"].ContextMenu.Frame["Ring Spinner"].OuterRing
   
   --Initialize iterative values
   local playerSpeed = nil
   local speedAdditive = 0
   local angleForwards = 0
   local angleBackwards = 0
   
   newSpinner.extraSpeed = 0
   newSpinner.Shifting = false
   
   --Connect to the step after simulation, least impactful
   newSpinner.Connection = RunService.PostSimulation:Connect(function()
      --Get the velocity of the player's rootpart
      playerSpeed = Player.Character.HumanoidRootPart.AssemblyLinearVelocity.magnitude
      
      --Create a proper factor for the ring speed. Can be adjusted with external values
      --[[Current Logic:
      Player speed is in studs/sec, so divide by 60 assuming 60FPS
      Extra speed additive is zero for now
      Manual additive is 1 for now
      ]]
      speedAdditive = .3 + (playerSpeed/60) + newSpinner.extraSpeed
      
      --Calculate the forward and backward angles using the modulus of the maximum angle
      angleForwards = (angleForwards + speedAdditive) % 180
      angleBackwards = (angleBackwards - speedAdditive) % -180
      
      --Assign the rotation values instantaneously
      newSpinner.innerRing.Rotation = angleForwards
      newSpinner.outerRing.Rotation = angleBackwards
   end)
   
   return newSpinner
end

return Spinner