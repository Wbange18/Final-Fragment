--[[NOTICE: Due to a workaround, the previously existing multiclient weapon functionality has been removed
as of Bumble version 2.2, or roblox's V15.]]

local Engine = _G.Engine

--Get Services and Classes
local AccessoryService = Engine.Services.AccessoryService
local Weapon = Engine.Classes.Weapon

local WeaponService = {}

WeaponService.__index = WeaponService

WeaponService.Weapon = nil

--METHODS==============================================================

--[[GiveWeapon
Give a weapon to the player. Remove any equipped weapon, as only one can exist at a time.
@method
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
	
	local Player = game.Players.LocalPlayer
	
	local newWeapon = AccessoryService:AddAccessory(WeaponInstance, true)
	
	self.Weapon = newWeapon
	
	local WeaponObject = Weapon.new(newWeapon, Player, true, true)
	
	return newWeapon
end

--[[RemoveWeapon
Remove a weapon from the player.
@method
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
