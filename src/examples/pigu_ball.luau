local RunService = game:GetService('RunService')

local physics = require('../include/physics')
local ball = physics.entity()

local assets = workspace:WaitForChild('assets') :: Folder
local ball_asset = assets:WaitForChild('ball') :: Part
local originPart = assets:WaitForChild('origin') :: Part
local targetPart = assets:WaitForChild('target') :: Part

local elasticity = 80

ball.flags.fGravity = true
ball.flags.fCollideWorld = true

physics.world.gravity = 100

local s
while true do
	if s then
		s:Disconnect()
	end
	ball.cframe = originPart.CFrame
	ball.velocity = (targetPart.Position - originPart.Position).Unit * elasticity
		+ Vector3.new(0, elasticity, 0)
	s = RunService.Heartbeat:Connect(function(deltaTime)
		physics.frame(ball, deltaTime)
		ball_asset.CFrame = ball.cframe
	end)
	task.wait(3)
end
