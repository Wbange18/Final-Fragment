--[[Created by Galvarino, all rights reserved.
🐝 Engine (Bumble Engine) Is an engine created for the initial version of Final Fragment.
This iteration uses Services, Classes, and Controllers to constitute the game's scripting.
Services and Classes are provided by the Engine and are stored within its' internal structure,
but controllers must be written to use the Engine as it cannot be called within itself.

Modules:
>Engine==================================================================
Provides helpful tools for using Bumble Services, Classes, and Resources. Additionally, includes
extra Classes for useful functions.
TODO:[DOCUMENTATION_NEEDED]
========================================================================

>EngineTools==============================================================
Provides functions for general but tedious tasks, for example tweens.
TODO:[DOCUMENTATION_NEEDED]
========================================================================

>NotificationService========================================================
Provides notifications to the player for information, powerups, timers, etc. Currently, due to old
code, functions must be called from Notification, not NotificationService.
Parameters:
Notification.new(
	subject, iconLink, duration, timer, dismissable, content, priority, interface
)
subject{string}: Subject text of the notification. Always visible, even when minimized.
iconLink{string}: Complete asset link to the desired icon. Always visible.
duration{number}: Time the notification will exist if not manually or internally closed.
timer{bool}: Whether or not to show the timer.
dismissable{bool}: Whether or not the notification can be closed with a button.
content{string}: Text for information, only visible when maximized.
priority{string}: Priority of the notification when added to the list. (First, Next, Last)
interface{object}: Interface to open when clicked. This is specifically for hints or new 
collectibles.
========================================================================

>MechanicService===========================================================
Provides a service for mechanics to be added and removed from the game. This is useful
for adding new mechanics or removing old ones, and allows management of entire classes of
mechanics as well.
TODO:[DOCUMENTATION_NEEDED]
========================================================================

]]

--[[STORAGE=

--GetClass
Return either a folder instance or module depending on the input name.
@method {Engine}
@param {string} ClassName - The name of the Class to look up.

@return {instance/module} - The resultant Class.

function Engine:GetClass(ClassName)
	local Class

	Class = Engine.Tools:Find(Bumble.Classes, ClassName)
	if not Class then
		print ("Class search failed.")
	end

	return Class
end

--GetService
Return a service instance from the Bumble Engine's Services.
@method {Engine}
@param {string} serviceName - The name of the service to look up.

@return {instance} service - The resultant service.

function Engine:GetService(serviceName)
	local Service

	Service = Engine.Tools:Find(Bumble.Services, serviceName)
	if not Service then
		print ("Service search failed.")
	end

	return Service
end
]]