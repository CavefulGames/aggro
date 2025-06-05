local physics_main_utils = require('./physics_main_utils')

local physics = {}

function physics.entity(): physics_main_utils.Entity
    local self = physics_main_utils.entity()
    
    self.flags.fCollide = true
    self.flags.fGravity = true

    return self
end 

function physics.frame(self: physics_main_utils.Entity, deltaTime: number)
    local position = physics_main_utils.physicsPosition(self, deltaTime)

    local angle = physics_main_utils.physicsAngular(self, deltaTime)
    
    physics_main_utils.physicsTrace(self, self.position, position - self.position)

    self.position = self.position + position
    self.angle = self.angle * angle
    self.cframe = CFrame.new(self.position) * self.angle
end

function physics.collisionBouce()

end

return physics
