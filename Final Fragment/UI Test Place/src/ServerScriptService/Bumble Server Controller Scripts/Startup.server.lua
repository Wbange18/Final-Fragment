local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Get Bumble Engine
local Bumble = ReplicatedStorage:WaitForChild("Bumble Engine")

--Get Bumble Engine Module
local Engine = require(Bumble.Engine)

game.Workspace["Local Mechanics"].Parent = ReplicatedStorage

Engine:InitializeClasses("Build Server")
Engine:InitializeServices("Run Server")

--use the engine to recursively require all existing services that need to be loaded