local grenade = require('../include/grenade')

local part = Instance.new('Part', workspace)
part.Name = 'Grenade'
part.Size = Vector3.one * 2
part.Anchored = true

local entity =  grenade.grenade()
entity.cframe = CFrame.new(0, 0, 0)
entity.velocity = Vector3.new(300, 100, 0)

entity.flags.fGravity = true
entity.flags.fCollideWorld = true

local RunService = game:GetService('RunService')

RunService.Heartbeat:Connect(function(deltaTime)
	grenade.frame(entity, deltaTime)
	part.CFrame = entity.cframe
end)
