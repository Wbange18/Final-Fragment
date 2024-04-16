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
]]
function NotificationService:CreateNotification(
	subject, iconLink, duration, timerVisible, isDismissable, content, priority
)

	--Callback for when notification is removed
	local function destroyed(notification)
		NotificationService.CurrentFrame:RemoveNotification(notification)
	end

	local newNotification = Notification.new(
		subject, iconLink, duration, timerVisible, isDismissable, content, priority, destroyed
	)

	NotificationService.CurrentFrame:AddNotification(newNotification)
	
	return newNotification
	--Got to here, but I need to work on the creation/destruction of the frame itself
end

--[[RemoveNotification

]]

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

print("Successfully initialized!")

return NotificationService
