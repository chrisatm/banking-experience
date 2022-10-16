local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Emitter = {}
Emitter.__index = Emitter

function Emitter.new(char, color)
	local self = setmetatable({}, Emitter)
	
	self.EmitterTime = 1
	
	self.PartEmitter = Instance.new("ParticleEmitter")
	self.PartEmitter.Color = color
	self.PartEmitter.Parent = char.HumanoidRootPart
	
	self.PartEmitter.Lifetime = NumberRange.new(1,2)
	self.PartEmitter.Rate = 1000
	self.PartEmitter.Speed = NumberRange.new(1,3)
	
	self:Init()
	
	return self
end



function Emitter:Init()
	task.delay(self.EmitterTime, function()
		self:Destroy()
	end)
end


function Emitter:Destroy()
	self.PartEmitter:Destroy()
end


return Emitter
