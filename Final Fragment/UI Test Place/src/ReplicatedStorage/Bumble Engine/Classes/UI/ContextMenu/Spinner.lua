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
function Spinner:Change(speed, smoothing)
   self.extraSpeed = speed
   if smoothing ~= nil and smoothing ~= 0 then
      coroutine.wrap(function()
         repeat
            self.extraSpeed += speed/smoothing
            task.wait(.1)
         until self.extraSpeed >= speed
      end)()
   end
   return
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
   
   --Connect to the step after simulation, least impactful
   newSpinner.Connection = RunService.PostSimulation:Connect(function()
      --Get the velocity of the player's rootpart
      playerSpeed = Player.Character.HumanoidRootPart.assemblylinearvelocity.magnitude
      
      --Create a proper factor for the ring speed. Can be adjusted with external values
      --[[Current Logic:
      Player speed is in studs/sec, so divide by 60 assuming 60FPS
      Extra speed additive is zero for now
      Manual additive is 1 for now
      ]]
      speedAdditive = 1 + (playerSpeed/60) + newSpinner.extraSpeed
      
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