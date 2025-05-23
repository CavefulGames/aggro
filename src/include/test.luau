local physics = require('./physics')

local part = workspace:WaitForChild('Part')
local en = physics.entity()

en.cframe = CFrame.new(0, 6, 0) * CFrame.Angles(90, 90, 90)
en.tempVelocity = Vector3.new(100, 50, 40)
en.flags.fGravity = true
en.flags.fCollideWorld = true

task.wait(1)

game:GetService('RunService').Heartbeat:Connect(function(dt)
	physics.update(dt)
	part.CFrame = en.cframe
end)
