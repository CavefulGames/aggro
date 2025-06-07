local physics = require('./physics')

local tempentity = {}

function tempentity.frame(self: physics.Entity, deltaTime: number)
    local gravity = physics.gravity * deltaTime

    local localOrigin = self.cframe.Position

    self.isColliding = false

    self.velocity = self.velocity * deltaTime
    
    self.cframe = CFrame.new(localOrigin + self.velocity * deltaTime) * CFrame.Angles(self.cframe:ToEulerAnglesXYZ())

    self.angularVelocity = self.velocity * deltaTime
    
    local angularVelocity = self.angularVelocity * math.pi / 180
    self.cframe *= CFrame.Angles(angularVelocity.X, angularVelocity.Y, angularVelocity.Z)

    local distance, result = physics.physicsTraceLine(localOrigin, self.cframe.Position)
    
    if not result then
        if self.flags.fGravity then
            self.velocity -= Vector3.new(0, gravity, 0)
        end

        return
    end

    if not self.flags.fCollideWorld then
        return        
    end

    self.normal = result.Normal

    if result.Distance / distance == 1 then
        return
    end

    local dampingFactor = 1
    
    self.isColliding = true

    if self.flags.fGravity then
        dampingFactor *= 0.5

        if result.Normal.Y > 0.9 then
            if self.velocity.Y <= 0 and self.velocity.Y >= -gravity * 3 then
                dampingFactor = 0

                self.flags.fGravity = false
                self.flags.fCollideWorld = false
                
                local _, y, _ = self.cframe:ToEulerAnglesYXZ()
                self.cframe = CFrame.new(self.cframe.Position) * CFrame.Angles(0, y, 0)
            end
        end
    end

    if dampingFactor ~= 0 then
        local productVelocity = self.velocity:Dot(result.Normal)
        
        self.velocity = self.velocity + -2 * productVelocity * result.Normal
        local x, y, z = self.cframe:ToEulerAnglesXYZ()
        self.cframe = CFrame.new(self.cframe.Position) * CFrame.Angles(x, -y, z)
    end

    if dampingFactor ~= 1 then
        self.velocity = self.velocity * dampingFactor

        local x, y, z = self.cframe:ToEulerAnglesXYZ()
		self.cframe = CFrame.new(self.cframe.Position) * CFrame.Angles(x * 0.9, y * 0.9, z * 0.9)
    end
end

return tempentity
