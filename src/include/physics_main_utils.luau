export type Entity = {
    --// 사용자가 바꿀수 있는 부분
    angularVelocity: Vector3 , --// 각속도 (Vector3) (deg)
    velocity: Vector3, --// 속도 (Vector3)

    --// 사용자가 바꿀수 없는 부분
    cframe: CFrame, --// 위치와 각도 (CFrame)
    position: Vector3, --// 위치 (Vector3)
    angle: CFrame, --// 각도 (CFrame Angle)

    --// 충돌할 Entity의 크기
    collisionSize: Vector3,

    --// Flag 들 (상태관리)
    flags: {
        fCollide: boolean?, --// 충돌하는지
        fGravity: boolean?, --// 중력의 영향을 받는지
    },

    --// trace
    normal: Vector3,
    isColliding: boolean,
}

local physics_main_utils = {}

--// acceleration of gravity
physics_main_utils.gravity = 169

--[=[
	@within physics_main_utils
	@tag Method
	@method entity

    Create an Entity to be used when calculating Physics.

    @return entity
]=]
function physics_main_utils.entity(): Entity
    return {
        angularVelocity = Vector3.zero,
        velocity = Vector3.zero,

        cframe = CFrame.new(Vector3.zero),
        position = Vector3.zero,
        angle = CFrame.Angles(0, 0, 0),

        collisionSize = Vector3.zero,
    
        flags = {},

        normal = Vector3.zero,
        isColliding = false,
    }
end

--[=[
	@within physics_main_utils
	@tag Method
	@method physicsPosition

    Create move distance and calculate velocity with velocity

    @return entity move distance
]=]
function physics_main_utils.physicsPosition(self: Entity, deltaTime: number): Vector3
    --// if Entity is colliding then, return no move 
    if self.isColliding then
        return Vector3.zero
    end

    --// s = v * t
    local distance = self.velocity * deltaTime

    --// if not use gravity then, return distance
    if not self.flags.fGravity then
        return distance
    end

    --// a = v / t
    --// v = a * t
    local velocity = self.velocity

    --// apply gravity to velocity
    self.velocity = Vector3.new(
        velocity.X,
        velocity.Y - physics_main_utils.gravity * deltaTime,
        velocity.Z
    )

    --// average velocity = (v0 + v1) / 2
    --// s(distance) = v(velocity) * t(deltaTime)
    distance = Vector3.new(
        velocity.X,
        (velocity.Y + self.velocity.Y) / 2,
        velocity.Z
    ) * deltaTime

    return distance
end

--[=[
	@within physics_main_utils
	@tag Method
	@method physicsAngular

    Calculate the angle of rotation.

    @return rotated angle
]=]
function physics_main_utils.physicsAngular(self: Entity, deltaTime: number)
    --// θ = ω × t
    --// θ(deg) * pi / 180 = θ(rad)
    local angle = self.angularVelocity * deltaTime * math.pi / 180

    --// apply angle to cframe
    return CFrame.Angles(
        angle.X,
        angle.Y,
        angle.Z
    )
end

--[=[
	@within physics_main_utils
	@tag Method
	@method physicsTrace

    Calculate trace line
]=]
function physics_main_utils.physicsTrace(self: Entity, origin: Vector3, distance: Vector3)
    --// entity collision size
    local collisionSize = self.collisionSize

    --// origin -> distance
    local traceDistance = distance - origin

    --// sing * collision size is calculate the volume
    local trace = workspace:Raycast(
        origin, 
        traceDistance + self.velocity:Sign() * collisionSize
    )

    self.isColliding = false

    --// if not colliding then, return
    if not trace then
        return
    end

    if traceDistance / trace.Distance == 1 then
        return
    end

    self.isColliding = true

    self.normal = trace.Normal
end

return physics_main_utils
