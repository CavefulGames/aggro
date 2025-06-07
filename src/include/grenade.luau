local physics = require('./physics')
local math_main_utils = require('./math_main_utils')

local grenade = {}

function grenade.frame(self: physics.Entity, deltaTime: number)
    self.position = self.position + physics.physicsPosition(self, deltaTime)
    self.angle = self.angle * physics.physicsAngular(self, deltaTime)

    if self.isColliding then
        grenade.grenadeCollision(self, deltaTime)
    end
end

function grenade.grenadeCollision(self: physics.Entity, deltaTime: number)
    local totalElasticity = math.clamp(self.elasticity, 0, 0.9)

    local velocity = physics.physicsClipVelocity(self.velocity, self.normal, 2) * totalElasticity
    
    local speedSquare = velocity:Dot(velocity)

    if self.normal.Y > 0.7 then
        self.velocity = velocity

        if speedSquare < (30 * 30 * 0.0254) then
            self.velocity = Vector3.zero
            
            local angularVelocity = math_main_utils.vectorAngle(self.normal)

            angularVelocity = Vector3.new(angularVelocity.Y, math.random(1, 360), angularVelocity.Z)

            self.angularVelocity = angularVelocity
            
            self.flags.fGravity = false
            self.flags.fCollideWorld = false
        end
    else
        if speedSquare < (30 * 30 * 0.0254) then
            self.velocity = Vector3.zero
            self.angularVelocity = Vector3.zero
        else
            self.velocity = velocity
        end
    end
end
