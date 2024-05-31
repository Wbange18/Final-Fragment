local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Player = game.Players.LocalPlayer

ReplicatedStorage:WaitForChild("Bumble Engine")

--Get Bumble Engine Module
local EngineTools = require(ReplicatedStorage["Bumble Engine"].Classes.Engine.EngineTools)
local Engine = require(ReplicatedStorage["Bumble Engine"].Engine)


EngineTools.LockPlayer()

Engine:InitializeClasses("Build Client")
Engine:InitializeServices("Run Client")

local FFDataService = require(ReplicatedStorage["Bumble Engine"].Services.FFDataService)
local FFNotificationService = require(ReplicatedStorage["Bumble Engine"].Services.FFNotificationService)
local MechanicService = require(ReplicatedStorage["Bumble Engine"].Services.MechanicService)
local WeaponService = require(ReplicatedStorage["Bumble Engine"].Services.WeaponService)

--local MusicService = Engine.Services.MusicService

local MechanicsFolder = ReplicatedStorage:WaitForChild("Local Mechanics")

local newMechanicsFolder = MechanicsFolder:Clone()

MechanicsFolder:Destroy()

newMechanicsFolder.Parent = game.Workspace.CurrentCamera

MechanicService:StartAllMechanics()
EngineTools.UnlockPlayer()

local Pickaxe = Engine.Resources.Weapons:WaitForChild("Pickaxe")

WeaponService:GiveWeapon(Pickaxe)

--script.Parent:WaitForChild("FirstTrack")

--MusicService:Play(script.Parent.FirstTrack.Value)

FFNotificationService:CreateNotification(
	"2", "", 12, true, true, "Gung ho", "First", Color3.new(0.807843, 0.384314, 0.384314)
)

FFNotificationService:CreateNotification(
	"4", "", 9, true, true, "Gung ho", "Next", Color3.new(0.3254901960784314, 0.20784313725490197, 0.6549019607843137)
)
FFNotificationService:CreateNotification(
	"5", "", 16, true, true, "Gung ho", "Next"
)
wait(1)
FFNotificationService:CreateNotification(
	"1", "", 20, true, true, "Gung ho", "First"
)
FFNotificationService:CreateNotification(
	"3", "", 10, true, true, "Gung ho", "Next"
)
FFNotificationService:CreateNotification(
	"6", "", 5, true, true, "Gung ho", "Last"
)

FFDataService:AddToSet("Collectibles", "R56")
FFDataService:AddToSet("Collectibles", "R56")
FFDataService:AddToSet("Collectibles", "R56")
FFDataService:AddToSet("Collectibles", "R56")


print(FFDataService:MatchFromSet("Collectibles", "R56"))

FFDataService:RemoveFromSet("Collectibles", "R56")

print(FFDataService:MatchFromSet("Collectibles", "R56"))