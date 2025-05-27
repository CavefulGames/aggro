local grenade = require('../include/grenade')
local physics = require('../include/physics')
local tempentity = require('../include/tempentity')

local part = Instance.new('Part', workspace)
part.Name = 'Grenade'
part.Size = Vector3.one * 2
part.Anchored = true

local entity =  physics.entity()
entity.cframe = CFrame.new(0, 0, 0)
entity.velocity = Vector3.new(50, 50, 0)

entity.flags.fGravity = true
entity.flags.fCollideWorld = true

local RunService = game:GetService('RunService')

RunService.Heartbeat:Connect(function(dt)
	-- part.Position += physics.physicsGravity(entity, dt)
	-- tempentity.frame(entity, dt)
	-- part.CFrame = entity.cframe
end)
