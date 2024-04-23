local Engine = _G.Engine

--Get Notification Class
local Notification = Engine.Classes.Notification

local NotificationFrame = Engine.Classes["Notification Frame"]

local NotificationService = {}

--Set the table index to the Notification table
NotificationService.__index = NotificationService

NotificationService.CurrentFrame = NotificationFrame.new()

--METHODS=====================================================================

--[[CreateNotification
Slight abstraction of Notification.new, but handles some important properties.
@method
@param [SEE NOTIFICATION CLASS]
@param callback - optional function to run when the notification is destroyed or manually cancelled.
]]
function NotificationService:CreateNotification(
	subject, iconLink, duration, timerVisible, isDismissable, content, priority, notificationColor, callback
)

	--Callback for when notification is removed
	local function destroyed(notification)
		NotificationService:RemoveNotification(notification)

		--Extra callback for scripts that called this event
		if callback ~= nil then
			callback()
			return
		end
	end

	local newNotification = Notification.new(
		subject, iconLink, duration, timerVisible, isDismissable, content, priority, notificationColor, destroyed
	)

	NotificationService.CurrentFrame:AddNotification(newNotification)
	
	return newNotification
end

--[[RemoveNotification
Call related classes to remove the notification following signal of removal
@method
@param {object} notification - Notification to remove
]]
function NotificationService:RemoveNotification(notification)
	NotificationService.CurrentFrame:RemoveNotification(notification)
	return
end

--[[ResetFrame
Reset the notification frame when the player dies.
]]
function NotificationService:ResetFrame()
	NotificationService.CurrentFrame:Destroy()
	NotificationService.CurrentFrame = NotificationFrame.new()
end

--DEFINITION===============================================================

--[[Events:
Character death
]]

local DeathEvent = Engine:GetResource("Character Died")
local DeathConnection

DeathConnection = DeathEvent.Event:Connect(function()
	NotificationService:ResetFrame()
end)

return NotificationService
