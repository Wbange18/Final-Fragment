local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--[[EngineTools: Common blocks of code to be quickly accessed by all scripts.]]

local Tools = {}
--Tool variables

local BoolTable = {
	[true] = 1,
	[false] = 0
}

--[[Find:
Locate an item in a given directory.
@param {instance} Directory - The directory to search.
@param {string} itemName - The name of the item to search for.

@return {instance} result - The resultant item.
]]
function Tools:Find(Directory, itemName)
	local item

	for i, child in ipairs(Directory:GetDescendants()) do
		if child.Name == itemName then
			item = child
		end
	end
	if not item then
		print("ERROR: Could not find requested item.")
	end

	return item
end

--[[QuickTween:
Quickly create a tween.
@param {instance} object - The object to tween.
@param {number} duration - The time in seconds for the tween to last.
@param {table} properties - A table containing the properties to tween and their values.
@param {Enum.EasingStyle} easingStyle - The style of the tween.
@param {Enum.EasingDirection} easingDirection - The direction of the tween.
]]
function Tools:QuickTween(item, duration, properties, easingStyle, easingDirection)
	--Optional Arguments
	easingStyle = easingStyle or Enum.EasingStyle.Sine
	easingDirection = easingDirection or Enum.EasingDirection.Out

	local info = TweenInfo.new(
		duration,
		easingStyle,
		easingDirection
	)

	local tween = TweenService:Create(item, info, properties)
	tween:Play()
	return tween
end

--[[FadeTween:
Fade out an element and fade in another.
@param {instance} item1 - The item to fade in.
@param {instance} item2 - The item to fade out.
@param {number} duration - The time to fade.
@param {table} item1Properties - The optional properties of item 1.
@param {table} item2Properties - The optional properties of item 2.
@param {Enum.EasingStyle} easingStyle - Optional argument for style.
@param {Enum.EasingDirection} easingDirection1 - Optional argument for direction.
@param {Enum.EasingDirection} easingDirection2 - Optional argument for direction.
]]
function Tools:FadeTween(
	item1, item2, duration, item1Properties, item2Properties, easingStyle, easingDirection1, easingDirection2
)
	--Optional Arguments
	item1Properties = item1Properties or {ImageTransparency = 0, Visible = true}
	item2Properties = item2Properties or {ImageTransparency = 1, Visible = false}
	easingStyle = easingStyle or Enum.EasingStyle.Sine
	easingDirection1 = easingDirection1 or Enum.EasingDirection.Out
	easingDirection2 = easingDirection2 or Enum.EasingDirection.In

	Tools:QuickTween(item1, duration, {ImageTransparency = 0, Visible = true},easingStyle ,easingDirection1)
	Tools:QuickTween(item2, duration, {ImageTransparency = 1, Visible = false}, easingStyle, easingDirection2)
end

--[[QuickAnimation:
Quickly create and run an animation on the player.
@param {object} Animation - Animation object to run.
@return {object} AnimationObject - Resulting animation object.
]]
function Tools:QuickAnimation(Animation)
	local Player = Tools:GetPlayer()
	local AnimationObject = Player.Character.Humanoid:LoadAnimation(Animation)
	AnimationObject.Priority = Enum.AnimationPriority.Action
	AnimationObject:Play()
	return AnimationObject
end

--[[Generate ID:
Generate a character ID
@param {number} length - The length of the ID

@return {string} ID - The resultant ID
]]
function Tools:GenerateID(length)
	local ID = ""

	for i = 1, length do
		ID = ID .. string.char(math.random(65,90))
	end

	return ID
end

--[[BoolToNumber:
Convert true or false to a number.
@param {boolean} bool - The bool to convert to a number
@return number - The resulting number. (true = 1, false = 0)
]]
function Tools:BoolToNumber(bool)
	return BoolTable[bool]
end

--[[Flip:
Flips a 1 or 0 to the opposite.
@param {number} bit - Bit to flip
@return {number} bit - Flipped bit
]]
function Tools:Flip(bit)
	return math.abs(bit - 1)
end

--[[GetPlayer:
Get the local player, or get a player by userId.
@param {string} userId - Optional userId.
]]
function Tools:GetPlayer(userId)
	local Player
	
	if userId then
		for _, player in ipairs(game.Players:GetPlayers()) do
			if player.userId == userId then
				Player = player
				break
			end
		end
		
		return Player
	end
	
	--If no name, assume clientside behavior.
	Player = game.Players.LocalPlayer
	
	return Player
end

--[[GetCharacter:
Get the character of the local player, or by a userId.
@param {string} userId - Optional userId.
]]
function Tools:GetCharacter(userId)
	local Player
	
	Player = self:GetPlayer(userId)

	return Player.Character or Player.CharacterAdded:Wait()
end

--[[LockPlayer:
Lock the current player in place, disabling reset, walkspeed, and jumpheight.
]]
function Tools:LockPlayer()
	local Player = game.Players.LocalPlayer
	local Character
	
	repeat
		task.wait(.2)
		Character = Player.Character
	until Character ~= nil

	--workspace:WaitForChild(Player.Name):WaitForChild("Humanoid").WalkSpeed = 0
	Character:WaitForChild("Humanoid").WalkSpeed = 0
	
	repeat local success = pcall(function()
		 game:FindService("StarterGui"):SetCore("ResetButtonCallback", false)
	 end)
	 task.wait(0.2) until success
end

--[[UnlockPlayer:
Reverse the effects of LockPlayer.
]]
function Tools:UnlockPlayer()
	local Player = game.Players.LocalPlayer
	game:FindService("StarterGui"):SetCore("ResetButtonCallback", true)
	Player.Character.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
end

--[[CreateRemote:
Create a remote parented to the given object, or replicated storage by default.

@param {string} name - Name of the remote.
@param {object} Parent - Parent of the remote if not ReplicatedService.
Make sure this is readable by the server!
@return {object} Remote - Constructed remote object.
]]
function Tools:CreateRemote(name, Parent)
	if RunService:IsClient() then
		return nil
	end
	Parent = Parent or ReplicatedStorage
	local Remote = Instance.new("RemoteEvent")
	Remote.Name = name
	Remote.Parent = Parent
	return Remote
end

--[[CreateRemoteFunction:
Create a remote function
@param {string} name - Name of the remote function
@param {object} Parent - Optional parent of the remote
@return {object} RemoteFunction - Constructed remote function object.
]]
function Tools:CreateRemoteFunction(name, Parent)
	if RunService:IsClient() then
		return nil
	end
	Parent = Parent or ReplicatedStorage
	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = name
	remoteFunction.Parent = Parent
	return remoteFunction
end

--[[WaitForEvent:
Wait for a remote event to occur. This could also be done with remote functions, but it works.
May be replaced in the future.
 {client}
@param {object} Remote - Event to wait for
@return {bool} result - Result data of event, if any.
]]
function Tools:WaitForEvent(Remote, key)
	local _, keyInput, resultInput
	if RunService:IsClient() then
		repeat
			keyInput, resultInput = Remote.OnClientEvent:Wait()
		until keyInput == key
		return resultInput
	end
	if RunService:IsServer() then
		repeat
			_, keyInput, resultInput = Remote.OnClientEvent:Wait()
		until keyInput == key
		return resultInput
	end
	return
end

--[[CSVToArray:
Convert a comma-separated value string to an array. The operation is simple but difficult
to remember.
@param {string} stringCSV - String to separate.
@return {array} array - Resultant array.
]]
function Tools:CSVToArray(stringCSV)
	local array = string.split(stringCSV, ",")
	return array
end

--[[GetCenterOfMass:
@param {object} Parts - Parts to get center of mass of.
]]
function Tools:GetCenterOfMass(Parts)

	local TotalMass = 0
	local SumOfMasses = Vector3.new(0, 0, 0)

	for _, Part in ipairs(Parts) do
		TotalMass = TotalMass + Part:GetMass()
		SumOfMasses = SumOfMasses + Part:GetMass() * Part.Position
	end

	return SumOfMasses/TotalMass, TotalMass
end

--[[GetAnimatorFromPlayer:
Grabs the current animator from a given player.
@param {instance} Player - Player to grab the animator from
@return {instance} Animator - Target animator
]]
function Tools:GetAnimatorFromPlayer(Player)
	local Animator
	
	if not
		pcall(function()
			Animator = Player.Character.Humanoid.Animator
		end)
	then
		print("Animator not found!")
		Animator = Player.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
	end
	
	return Animator
end

--[[WeldToM6D:
Convert a weld object to a Motor6D object. This function assumes the goal of this is for humanoid
animation.
@param {instance} weld - The target weld of the operation
@param {instance} motor - Optional parameter for existing motor to convert
@param {bool} reverseOrder - Optional parameter to cross-assign part 1 and 0
@param {bool} preserveWeld - Whether or not to keep the weld
@return {instance} motor - Finished motor6D
]]
function Tools:WeldToM6D(weld, preserveWeld)
	local motor = Instance.new("Motor6D")
	preserveWeld = preserveWeld or (preserveWeld == nil and false) --Default parameter is false
	local weldParent = weld.Parent --[[Necessary reference to the parent, as we will destroy it before
	assigning the parent]]
	
	motor.Name = weld.Name
	
	--Invert these values to change relativity to player from tool
	motor.Part0 = weld.Part1
	motor.Part1 = weld.Part0
	
	--[[Part0.CFrame * C0 = Part1.CFrame * C1 | C1 is not used, so it is set to I. Multiply
	the opposite side by the inverse of Part0.CFrame to solve for C0.
	]]
	motor.C0 = motor.Part1.CFrame * motor.Part0.CFrame:inverse()

	if preserveWeld ~= true then
		weld:Destroy()
	end

	motor.Parent = weldParent
	return motor
end

--[[GetDictLength:
Get length of a dictionary, as roblox doesn't support any way to do this currently.
@param {table} dict - "dictionary" table to get length of
@return {number} length - the length of the dictionary
]]
function Tools:GetDictLength(dict)
	local length = 0

	for _ in ipairs(dict) do
		length = length + 1
	end
	return length
end

--[[GetKey:
Get key of a value in a dictionary
@param {table} Table - Table to search
@param {any} Value - Value to match with key
@return {any} Key - Key of the value
]]
function Tools:GetKey(Table, Value)
	for i, value in ipairs(Table) do
		if value == Value then
			return i
		end
	end
	return
end


return Tools