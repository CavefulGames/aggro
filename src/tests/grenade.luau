local grenade = require('../include/grenade')

local part = Instance.new('Part', workspace)
part.Name = 'Grenade'
part.Size = Vector3.one * 2
part.Anchored = true
part.Color = Color3.new(1, 0, 0)

local entity =  grenade.entitiy()
entity.cframe = CFrame.new(0, 10, 0)
entity.velocity = Vector3.new(100, 100, 0)

entity.flags.fGravity = true
entity.flags.fCollideWorld = true

entity.render = part

local RunService = game:GetService('RunService')

task.wait(1)

RunService.Heartbeat:Connect(function(deltaTime)
	grenade.update(deltaTime)
end)
