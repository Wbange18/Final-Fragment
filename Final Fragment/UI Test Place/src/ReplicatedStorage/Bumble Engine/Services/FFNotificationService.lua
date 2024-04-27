local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Notification = require(ReplicatedStorage["Bumble Engine"].Classes.UI.Notifications.Notification)
local NotificationFrame = require(ReplicatedStorage["Bumble Engine"].Classes.UI.Notifications.NotificationFrame)
local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)
local FFNotificationService = {}

--Set the table index to the Notification table
FFNotificationService.__index = FFNotificationService

FFNotificationService.CurrentFrame = NotificationFrame.new()

--METHODS=====================================================================

--[[CreateNotification
Slight abstraction of Notification.new, but handles some important properties.

@param [SEE NOTIFICATION CLASS]
@param callback - optional function to run when the notification is destroyed or manually cancelled.
]]
function FFNotificationService:CreateNotification(
	subject, iconLink, duration, timerVisible, isDismissable, content, priority, notificationColor, callback
)

	--Callback for when notification is removed
	local function destroyed(notification)
		FFNotificationService:RemoveNotification(notification)

		--Extra callback for scripts that called this event
		if callback ~= nil then
			callback()
			return
		end
	end

	local newNotification = Notification.new(
		subject, iconLink, duration, timerVisible, isDismissable, content, priority, notificationColor, destroyed
	)

	FFNotificationService.CurrentFrame:AddNotification(newNotification)
	
	return newNotification
end

--[[RemoveNotification
Call related classes to remove the notification following signal of removal

@param {object} notification - Notification to remove
]]
function FFNotificationService:RemoveNotification(notification)
	FFNotificationService.CurrentFrame:RemoveNotification(notification)
	return
end

--[[ResetFrame
Reset the notification frame when the player dies.
]]
function FFNotificationService:ResetFrame()
	FFNotificationService.CurrentFrame:Destroy()
	FFNotificationService.CurrentFrame = NotificationFrame.new()
end

--DEFINITION===============================================================

--[[Events:
Character death
]]

local DeathEvent = Engine:GetResource("Character Died")

DeathEvent.Event:Connect(function()
	FFNotificationService:ResetFrame()
end)

return FFNotificationService