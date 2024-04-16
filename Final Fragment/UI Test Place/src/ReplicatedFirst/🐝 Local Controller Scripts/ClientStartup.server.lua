local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer

--Get Bumble Engine
local Bumble = ReplicatedStorage:WaitForChild("🐝 Engine")

--Get Bumble Engine Module
local Engine = require(Bumble.Engine)

Engine.Tools:LockPlayer()

Engine:InitializeClasses("Build Client")
Engine:InitializeServices("Run Client")

local FFDataService = Engine.Services.FFDataService
local MechanicService = Engine.Services.MechanicService
local WeaponService = Engine.Services.WeaponService
local MusicService = Engine.Services.MusicService

local NotificationService = Engine.Services.NotificationService

local MechanicsFolder = ReplicatedStorage:WaitForChild("Local Mechanics")

local newMechanicsFolder = MechanicsFolder:Clone()

MechanicsFolder:Destroy()

newMechanicsFolder.Parent = game.Workspace.CurrentCamera

MechanicService:StartAllMechanics()
Engine.Tools:UnlockPlayer()

local Pickaxe = Engine.Resources.Weapons:WaitForChild("Pickaxe")

WeaponService:GiveWeapon(Pickaxe)

--script.Parent:WaitForChild("FirstTrack")

--MusicService:Play(script.Parent.FirstTrack.Value)


NotificationService:CreateNotification(
	"2", "", 12, true, true, "Gung ho", "First"
)

NotificationService:CreateNotification(
	"4", "", 9, true, true, "Gung ho", "Next"
)
NotificationService:CreateNotification(
	"5", "", 16, true, true, "Gung ho", "Next"
)
wait(1)
NotificationService:CreateNotification(
	"1", "", 20, true, true, "Gung ho", "First"
)
NotificationService:CreateNotification(
	"3", "", 10, true, true, "Gung ho", "Next"
)
NotificationService:CreateNotification(
	"6", "", 5, true, true, "Gung ho", "Last"
)



FFDataService:AddToSet("Collectibles", "P56")
FFDataService:AddToSet("Collectibles", "P56")
FFDataService:AddToSet("Collectibles", "P56")
FFDataService:AddToSet("Collectibles", "P56")


print(FFDataService:MatchFromSet("Collectibles", "P56"))

FFDataService:RemoveFromSet("Collectibles", "P56")

print(FFDataService:MatchFromSet("Collectibles", "P56"))