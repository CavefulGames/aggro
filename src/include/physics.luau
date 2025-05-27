local world = require('./world')

export type Entity = typeof(setmetatable({} :: {
    angularVelocity: Vector3,
    velocity: Vector3, --// 속도 (v)
    acceleration: Vector3, --// 가속도 (a)
    
    cframe: CFrame, --// Entitiy 의 CFrame

    --// 플레그들 (앞의 f 는 flag 라는 뜻)
    flags: {
        fRotate: boolean?, --// 회전을 하는지
        fCollideWorld: boolean?, --// World 충돌을 받는지
        fGravity: boolean?, --// 중력의 영향을 받는지
        fSlowGravity: boolean?, --// 느린 중력의 영향을 받는지 (fGravity 가 켜저있다면 적용돼지 않음)
    },

    --// 레이케스트 법선백터
    normal: Vector3,

    --// 충돌여부
    isCollision: boolean,
}, {}))

local physics = {}

function physics.entity(): Entity
    return setmetatable({
        angularVelocity = Vector3.zero,
        velocity = Vector3.zero,
        acceleration = Vector3.zero,
    
        cframe = CFrame.new(Vector3.zero),
        
        flags = {},

        normal = Vector3.zero,

        isCollision = false,
    }, {})
end

function physics.physicsGravity(self: Entity, deltaTime: number): Vector3
    --// 현제 엔티티의 속도
    local velocity = self.velocity

    --// 중력을 적용한 y 속도 (현제 y - 중력 * dt)
    --// 등가속도 운동의 기본공식 (속도) v = v0 + at
    --// 중력은 아래로 작용하기에 중력가속도(a)를 빼줌
    --// 즉 현제 속도 (v0) - 중력가속도 (a) * deltaTime (t)
    local newYVelocity = velocity.Y - world.gravity * deltaTime

    --// 현제속도에 중력을 적용
    velocity = Vector3.new(velocity.X, newYVelocity, velocity.Z)

    --// 현제속도에 중력을 적용
    self.velocity = velocity

    --// 이동한 거리를 반환
    return Vector3.new(velocity.X * deltaTime, ((velocity.Y + newYVelocity) / 2) * deltaTime, self.cframe.Z + velocity.Z * deltaTime)
end

return physics
