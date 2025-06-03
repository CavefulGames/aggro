local physics = require('../include/physics')

local part = Instance.new('Part', workspace)
part.Name = 'Grenade'
part.Size = Vector3.one * 2
part.Anchored = true
part.Color = Color3.new(1, 0, 0)

local entity = physics.entity()
entity.cframe = CFrame.new(0, 10, 0)
entity.velocity = Vector3.new(3, 100, 0)
entity.angularVelocity = Vector3.one * 100 * math.pi / 180

entity.flags.fGravity = true
entity.flags.fCollideWorld = true

local RunService = game:GetService('RunService')

task.wait(1)

RunService.Heartbeat:Connect(function(deltaTime)
	physics.frame(entity, deltaTime)
	part.CFrame = entity.cframe
end)
