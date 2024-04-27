local UserInputService = game:GetService("UserInputService")
local Weapon = {}
Weapon.__index = Weapon

--METHODS=====================================================================

--[[Click
Function for when the player clicks, and it is caught by the script.

]]
function Weapon:Click()
	if self.CanClick == false then
		return
	end
	self.CanClick = false
	
	if self.State == "None" or self.State == "Deforming" then
		self.Actions["Form"]()
		self.Actions["Swing 1"]()
		return
	end
	
	if self.State == "Idle" then
		self.Actions["Swing 1"]()
		return
	end
	
	local StateNumber = tonumber(string.match(self.State, "%d+"))
	
	--Allow the second swing. This must be made exceptional as Forming and Swing 1 are both the same.
	if self.State == "Forming" or self.State == "Swing 1" then
		if StateNumber >= self.ComboMax then
			return
		end
		self.Actions["Swing 2"]()
		return
	end
	
	--Allow all future swings. The final swing is only declared in actions.
	if self.State == "Swing " .. StateNumber and StateNumber < self.ComboMax then
		self.Actions["Swing " .. (StateNumber + 1)]()
		return
	end
end

--CONSTRUCTORS===============================================================

--[[new
Create a new weapon object.

@param {object} WeaponObject - The ingame object to program.
@param {object} Player - The player to program the sword for.
@param {boolean} state - Whether or not the sword will damage.
@param {boolean} client - If the parent is the client's player or not.
]]
function Weapon.new(WeaponObject, Player, canKill, client)
	local newWeapon = {}
	setmetatable(newWeapon, Weapon)
	
	newWeapon.CanKill = canKill
	newWeapon.Client = client
	newWeapon.CanClick = true
	newWeapon.Player = Player
	
	newWeapon.State = "None"
	newWeapon.Actions = require(WeaponObject.Actions)
	
	newWeapon.Actions.Class = newWeapon
	
	newWeapon.LastAnimation = nil
	newWeapon.CurrentAnimation = nil
	
	newWeapon.Instance = WeaponObject
	
	newWeapon.waitTimes = newWeapon.Instance["Delay Configuration"]:GetAttributes()

	newWeapon.Animations = newWeapon.Instance.Animations

	newWeapon.Animator = newWeapon.Instance.Parent:WaitForChild("Humanoid"):WaitForChild("Animator")

	newWeapon.Animations.Parent = newWeapon.Instance.Parent:WaitForChild("Humanoid")

	
	
	newWeapon.ComboMax = WeaponObject:GetAttribute("ComboMax")
	newWeapon.Damage = WeaponObject:GetAttribute("Damage")
	newWeapon.ResetTime = WeaponObject:GetAttribute("ResetTime")
	newWeapon.Swing = WeaponObject:GetAttribute("Swing")
	newWeapon.WeaponName = WeaponObject:GetAttribute("WeaponName")
	
	if newWeapon.Client == true then
 		UserInputService.InputBegan:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				newWeapon:Click()
			end
		end)
	end
	
	return newWeapon
end

return Weapon
