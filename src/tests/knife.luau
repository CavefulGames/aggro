local knife_throwing = require('../include/knife_throwing')
local vector = require('../include/vecotr_main_utils')

local part = Instance.new('Part', workspace)
part.Name = 'Grenade'
part.Size = Vector3.one * 2
part.Anchored = true
part.Color = Color3.new(1, 0, 0)

local entity = knife_throwing.knife()
entity.cframe = CFrame.new(0, 10, 0)
entity.velocity = vector.create(00, 200, 3)

entity.flags.fGravity = true
entity.flags.fCollideWorld = true

local RunService = game:GetService('RunService')

task.wait(1)

RunService.Heartbeat:Connect(function(deltaTime)
	knife_throwing.frame(entity, deltaTime)
	part.CFrame = entity.cframe
end)
