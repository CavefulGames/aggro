local physics = require'../include/physics'

local RunService = game:GetService('RunService')

local knife_part = Instance.new('Part', workspace)
knife_part.Anchored = true
knife_part.Name = 'Knife'
knife_part.Size = Vector3.new(1, 5, 1)
knife_part.BrickColor = BrickColor.new('Really red')

local knife_physics = physics.entity()
knife_physics.cframe = CFrame.new(0, 10, 0)
knife_physics.angularVelocity = Vector3.new(0, 0, -500)
knife_physics.velocity = Vector3.new(60, 200, 0)

knife_physics.flags.fGravity = true
knife_physics.flags.fCollideWorld = true
knife_physics.flags.fCollisionBounce = true

task.wait(1)

RunService.Heartbeat:Connect(function(deltaTime)
	physics.frame(knife_physics, deltaTime)
    knife_part.CFrame = knife_physics.cframe
end)
