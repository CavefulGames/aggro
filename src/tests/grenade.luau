local grenade = require('../include/grenade')

local part = Instance.new('Part', workspace)
part.Name = 'Grenade'
part.Size = Vector3.one * 2
part.Anchored = true
part.Color = Color3.new(1, 0, 0)

local entity =  grenade.grenade()
entity.cframe = CFrame.new(0, 10, 0)
entity.velocity = Vector3.new(00, 200, 3)
entity.angularVelocity = Vector3.new(math.random(1, 100), math.random(1, 100), 0)

entity.flags.fGravity = true
entity.flags.fCollideWorld = true

local RunService = game:GetService('RunService')

task.wait(1)

RunService.Heartbeat:Connect(function(deltaTime)
	grenade.frame(entity, deltaTime)
	part.CFrame = entity.cframe
end)
