local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LaunchPlayerEvent = ReplicatedStorage.Signals.LaunchPlayer

local boundaries = game.Workspace.Boundaries.Dectectors

local EmitterModule = require(script.Parent.Emitter)


local PlayersTable = {}



local function removePlayerFromTable(plr)
	local playerIndex = table.find(PlayersTable, plr)
	table.remove(PlayersTable, playerIndex)
end


local function EmitPart(char)
	local colorKeypoints = {
		-- API: ColorSequenceKeypoint.new(time, color)
		ColorSequenceKeypoint.new( 0, Color3.new(0, 1, 1)),  -- At t=0, White
		ColorSequenceKeypoint.new(.1, Color3.new(0, 1, 1)), -- At t=.25, Orange
		ColorSequenceKeypoint.new(.2, Color3.new(0, 0, 1)), -- At t=.5, Red
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 1))   -- At t=1, Red
	}
	local colorSeq = ColorSequence.new(colorKeypoints)
	EmitterModule.new(char, colorSeq)
end


local function launchPlayer(plr, char)
	table.insert(PlayersTable, plr)
	EmitPart(char)
	LaunchPlayerEvent:FireClient(plr)
	task.delay(1, function(plr)
		removePlayerFromTable(plr)
	end)
end


local function checkHumanoid(plr)
	local value = false
	for i,v in pairs(PlayersTable) do
		if plr == v then
			value = true
			return value
		end
	end
	return value
end


local function LaunchPlayer(partTouched)
	local partParent = partTouched.Parent
	
	local humanoidRootPart = partParent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local player = game.Players:GetPlayerFromCharacter(partTouched.Parent)
		
		if #PlayersTable ~= 0 then
			-- check table to see if humanoid exists
			local isOnTableAlready = checkHumanoid(player)
			if isOnTableAlready == true then
				return
			else
				launchPlayer(player, partParent)
			end
		else
			launchPlayer(player, partParent)
		end
	end
end


local function InitBoundaries()
	for i,boundary in pairs(boundaries:GetChildren()) do
		boundary.Touched:Connect(LaunchPlayer)
	end
end

InitBoundaries()
