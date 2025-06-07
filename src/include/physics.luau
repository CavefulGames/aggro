local entity = require('./entity')
export type Entity = entity.Entity

local physics = {}
physics.gravity = 169

function physics.physicsClipVelocity(velocity: Vector3, normal: Vector3, overbounce: number)
    local backoff = velocity:Dot(normal) * overbounce

    local result = velocity - normal * backoff
    
    if result.X > -0.1 and result.X < 0.1 then
        result = Vector3.new(0, result.Y, result.Z)
    end

    if result.Y > -0.1 and result.Y < 0.1 then
        result = Vector3.new(result.X, 0, result.Z)
    end

    if result.Z > -0.1 and result.Z < 0.1 then
        result = Vector3.new(result.X, result.Y, 0)
    end

    return result
end

function physics.physicsTraceLine(origin: Vector3, current: Vector3): (number, RaycastResult?)
	local distance = current - origin

	return distance.Magnitude, workspace:Raycast(origin, distance.Unit * distance.Magnitude)
end

function physics.physicsAngular(self: Entity, deltaTime: number)
    local angle = self.angularVelocity * deltaTime * math.pi / 180
    return CFrame.Angles(angle.X, angle.Y, angle.Z)
end

function physics.physicsPosition(self: Entity, deltaTime: number): Vector3
    if self.isColliding then
        return Vector3.zero
    end

    local distance = self.velocity * deltaTime

    if not self.flags.fGravity then
        return distance
    end

    local velocity = self.velocity

    self.velocity = Vector3.new(
        velocity.X,
        velocity.Y - physics.gravity * deltaTime,
        velocity.Z
    )

    distance = Vector3.new(
        velocity.X,
        (velocity.Y + self.velocity.Y) / 2,
        velocity.Z
    ) * deltaTime

    return distance
end

function physics.physicsTrace(self: Entity, origin: Vector3, cureent: Vector3)
    local collisionSize = self.collisionSize / 2

    local distance, result = physics.physicsTraceLine(origin, cureent + (self.velocity:Sign() * collisionSize))

    self.isColliding = false

    if not result then
        return
    end

    if result.Distance / distance == 1 then
        return
    end

    self.normal = result.Normal
    self.isColliding = true
end

function physics.physicsCollisionBounce(self: Entity)
    local totalElasticity = 0.3

    local velocity = physics.physicsClipVelocity(self.velocity, self.normal, 2) * totalElasticity
    
    local speedSquare = velocity:Dot(velocity)

    if self.normal.Y > 0.7 then
        self.velocity = velocity

        if speedSquare < (30 * 30) then
            self.velocity = Vector3.zero
            self.angularVelocity = Vector3.zero
            self.flags.fGravity = false
            self.flags.fCollideWorld = false
        end

    else
        if speedSquare < (30 * 30) then
            self.velocity = Vector3.zero
            self.angularVelocity = Vector3.zero
        else
            self.velocity = velocity
        end
    end
end

return physics
