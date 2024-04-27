local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Weapon = require(ReplicatedStorage["Bumble Engine"].Classes.Tools.Weapon)
local AccessoryService = require(ReplicatedStorage["Bumble Engine"].Services.AccessoryService)

local WeaponService = {}

WeaponService.__index = WeaponService

WeaponService.Weapon = nil

--METHODS==============================================================

--[[GiveWeapon
Give a weapon to the player. Remove any equipped weapon, as only one can exist at a time.

@return {object} Weapon - Weapon given to the player.
]]
function WeaponService:GiveWeapon(WeaponInstance, Player)
	if self.Weapon ~= nil then
		if self.Weapon == WeaponInstance then
			self:RemoveWeapon()
		else
			return
		end
	end
	
	local LocalPlayer = game.Players.LocalPlayer
	
	local newWeapon = AccessoryService:AddAccessory(WeaponInstance, true)
	
	self.Weapon = newWeapon
	
	Weapon.new(newWeapon, LocalPlayer, true, true)
	
	return newWeapon
end

--[[RemoveWeapon
Remove a weapon from the player.

]]
function WeaponService:RemoveWeapon(WeaponInstance, Player)
	if self.Weapon == nil then
		return
	end
	AccessoryService:RemoveAccessory(self.Weapon)
	self.Weapon = nil
	return
end

return WeaponService
