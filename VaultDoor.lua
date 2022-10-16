local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")


local VaultDoor = {}
VaultDoor.__index = VaultDoor

function VaultDoor.new(vaultDoor)
	local self = setmetatable({}, VaultDoor)
	
	self.VaultDoorModel = vaultDoor
	self.MainVaultDoorPart = self.VaultDoorModel.MainVaultDoor
	self.VaultSpinner = self.VaultDoorModel.VaultSpinner.Center
	self.VaultParticles = game.Workspace.VaultDoorBottom.ParticleEmitter
	self.Hinge = vaultDoor.Hinge
	self.TweenInfo = TweenInfo.new()
	self.Offset = self.Hinge.CFrame:Inverse() * self.MainVaultDoorPart.CFrame
	self.heartBeatConnections = {}
	self.spinnerHeartbeatConnections = {}
	
	self.DoorMoving = false
	
	
	return self
end


function VaultDoor:handleHeartbeat(activate)
	if activate == false then
		if #self.heartBeatConnections > 0 then
			for i, connection in pairs(self.heartBeatConnections) do
				connection:Disconnect()
			end
		end
	else
		local connection = RunService.Heartbeat:Connect(function(dt)
			self.MainVaultDoorPart.CFrame = self.Hinge.CFrame * CFrame.Angles(0, math.rad(self.MainVaultDoorPart.Angle.Value), 0) * self.Offset
		end)
		table.insert(self.heartBeatConnections, connection)
	end
end


function VaultDoor:handleSpinnerHeartbeat(activate, isClockwise)
	if activate == false then
		if #self.spinnerHeartbeatConnections > 0 then
			for i, connection in pairs(self.spinnerHeartbeatConnections) do
				connection:Disconnect()
			end
		end
	else
		local x = 0
		local connection = RunService.Heartbeat:Connect(function(dt)
			self.VaultSpinner.CFrame = self.VaultSpinner.CFrame * CFrame.Angles(math.rad(x), 0, 0)
			if isClockwise == true then
				x = x + 0.1
			else
				x = x - 0.1
			end
		end)
		table.insert(self.spinnerHeartbeatConnections, connection)
	end
end


function VaultDoor:RotateSpinner(shouldSpin, isClockwise)
	if shouldSpin == true then
		self.VaultSpinner.Anchored = true
		self:handleSpinnerHeartbeat(true, isClockwise)
	else
		-- no spin
		self.VaultSpinner.Anchored = false
		self:handleSpinnerHeartbeat(false, isClockwise)
	end
end



function VaultDoor:Open()
	self.DoorMoving = true
	self.VaultParticles.Enabled = true
	local doorOpen = TweenService:Create(self.MainVaultDoorPart.Angle, self.TweenInfo, {Value = -90})
	self:handleHeartbeat(true)
	local shouldSpin = true
	local isClockwise = false
	self.MainVaultDoorPart.Sound:Play()
	self:RotateSpinner(shouldSpin, isClockwise)
	task.delay(3, function()
		self.VaultParticles.Enabled = false
		local shouldSpin = false
		local isClockwise = false
		self:RotateSpinner(shouldSpin, isClockwise)
		doorOpen:Play()
		doorOpen.Completed:Connect(function(playbackState)
			self.DoorMoving = false
			self:handleHeartbeat(false)
		end)
	end)
	
	task.delay(6, function()
		self:Close()
	end)
end


function VaultDoor:Close()
	self.DoorMoving = true
	local doorClose = TweenService:Create(self.MainVaultDoorPart.Angle, self.TweenInfo, {Value = 0})
	self:handleHeartbeat(true)
	self.MainVaultDoorPart.Sound:Play()
	doorClose:Play()
	task.delay(3, function()
		self.DoorMoving = false
		self:handleHeartbeat(false)
		local shouldSpin = true
		local isClockwise = true
		self:RotateSpinner(shouldSpin, isClockwise)
		wait(3)
		local shouldSpin = false
		local isClockwise = true
		self:RotateSpinner(shouldSpin, isClockwise)
	end)
end


function VaultDoor:Init()
	
end


function VaultDoor:Destroy()

end


return VaultDoor
