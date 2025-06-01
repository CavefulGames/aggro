local physics = require('../include/physics')

local knife_instance = Instance.new('Part', workspace)
knife_instance.Anchored = true
knife_instance.Size = Vector3.new(1, 4, 1)

local knife = physics.entity()
knife.flags.fGravity = true
knife.flags.fCollideWorld = true

knife.velocity = Vector3.new(0, 500, 0)
knife.angularVelocity = Vector3.new(100, 0, 0)
knife.cframe = CFrame.new(0, 10, 0)

local RunService = game:GetService('RunService')

RunService.Heartbeat:Connect(function(deltaTime)
    physics.frame(knife, deltaTime)
    knife_instance.CFrame = knife.cframe
end)
