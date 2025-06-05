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

    --// 상태 (사용자가 바꿀수 없는부분)
    isColliding: boolean, --// 충돌한 상태인지
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

        isColliding = false,
    }
end

--[=[
	@within physics_main_utils
	@tag Method
	@method physicsGravity

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
	@method physicsGravity

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



return physics_main_utils
