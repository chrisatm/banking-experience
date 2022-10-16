local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GaveItem = ReplicatedStorage.Signals.GaveItem
local LaunchPlayer = ReplicatedStorage.Signals.LaunchPlayer
local SendNotif = ReplicatedStorage.Signals.SendNotif
local UpdateRobbing = ReplicatedStorage.Signals.UpdateRobbing

local playerGui = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')
local screenGui = playerGui:WaitForChild('ScreenGui')
local NotifContainer = screenGui:WaitForChild('NotifContainer')

local ErrorSound = script:WaitForChild("ErrorSound")
local SuccessSound = script:WaitForChild("SuccessSound")


local function ATMNotif()
	-- play success sound
	SuccessSound:Play()
	NotifContainer.NotifFrame.NotifLabel.TextColor3 = Color3.new(0, 0, 0)
	NotifContainer.NotifFrame.NotifLabel.BackgroundColor3 = Color3.new(0, 170, 127)
	NotifContainer.NotifFrame.NotifLabel.Text = "You received an ATM Card!"
	NotifContainer.Visible = true
	task.delay(1.5, function()
		NotifContainer.Visible = false
	end)
end

local function ATMAlreadyNotif()
	-- play error sound
	ErrorSound:Play()
	NotifContainer.NotifFrame.NotifLabel.TextColor3 = Color3.new(255, 255, 255)
	NotifContainer.NotifFrame.NotifLabel.BackgroundColor3 = Color3.new(170, 0, 0)
	NotifContainer.NotifFrame.NotifLabel.Text = "You already have an ATM Card!"
	NotifContainer.Visible = true
	task.delay(1.5, function()
		NotifContainer.Visible = false
	end)
end

local function SecurityNotif()
	-- play success sound
	SuccessSound:Play()
	NotifContainer.NotifFrame.NotifLabel.TextColor3 = Color3.new(0, 0, 0)
	NotifContainer.NotifFrame.NotifLabel.BackgroundColor3 = Color3.new(0, 170, 127)
	NotifContainer.NotifFrame.NotifLabel.Text = "You received a Security Card!"
	NotifContainer.Visible = true
	task.delay(1.5, function()
		NotifContainer.Visible = false
	end)
end

local function SecurityAlreadyNotif()
	-- play error sound
	ErrorSound:Play()
	NotifContainer.NotifFrame.NotifLabel.TextColor3 = Color3.new(255, 255, 255)
	NotifContainer.NotifFrame.NotifLabel.BackgroundColor3 = Color3.new(170, 0, 0)
	NotifContainer.NotifFrame.NotifLabel.Text = "You already have a Security Card!"
	NotifContainer.Visible = true
	task.delay(1.5, function()
		NotifContainer.Visible = false
	end)
end

local function launchPlayer()

	local humanoidRootPart = game:GetService('Players').LocalPlayer.Character.HumanoidRootPart

	local rand1 = math.random(-1,1)
	local rand2 = math.random(-1,1)
	if rand1 == 0 then
		rand1 = 1
	end
	if rand2 == 0 then
		rand2 = 1
	end
	local dir1 = humanoidRootPart.AssemblyMass * 500 * rand1
	local dir2 = humanoidRootPart.AssemblyMass * 500 * rand2
	
	script.WhooshSound:Play()
	humanoidRootPart:ApplyImpulse(Vector3.new(dir1, humanoidRootPart.AssemblyMass * 100, dir2))
end

local function handleGaveItem(item, hasItem)
	if item.Name == "ATMCard" then
		if hasItem == false then
			ATMNotif()
		else
			ATMAlreadyNotif()
		end
	elseif item.Name == "SecurityCard" then
		if hasItem == false then
			SecurityNotif()
		else
			SecurityAlreadyNotif()
		end
	end
end

local function handleSendNotif(msg, isError)
	local textColor = Color3.new(255, 255, 255)
	local bgColor = Color3.new(170, 0, 0)
	local successTextColor = Color3.new(0, 0, 0)
	local successBgColor = Color3.new(0, 170, 127)
	local errorTextColor = Color3.new(255, 255, 255)
	local errorBgColor = Color3.new(170, 0, 0)
	local notifLength = 3
	-- play error sound
	if isError == true then
		-- error sound play 
		ErrorSound:Play()
		-- default text is error text
		textColor = errorTextColor
		bgColor = errorBgColor
	else
		-- notif sound play
		SuccessSound:Play()
		-- change text
		textColor = successTextColor
		bgColor = successBgColor
	end
	
	NotifContainer.NotifFrame.NotifLabel.TextColor3 = textColor
	NotifContainer.NotifFrame.NotifLabel.BackgroundColor3 = bgColor
	NotifContainer.NotifFrame.NotifLabel.Text = msg
	NotifContainer.Visible = true
	task.delay(notifLength, function()
		NotifContainer.Visible = false
	end)
end

local function updateRobbing(isRobbing)
	playerGui.MoneyGui.Enabled = isRobbing
end

SendNotif.OnClientEvent:Connect(handleSendNotif)
GaveItem.OnClientEvent:Connect(handleGaveItem)
LaunchPlayer.OnClientEvent:Connect(launchPlayer)
UpdateRobbing.OnClientEvent:Connect(updateRobbing)
