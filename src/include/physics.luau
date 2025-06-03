local world = require('./world')
local vector_main_utils = require('./vector_main_utils')

export type Entity = typeof(setmetatable({} :: {
    angularVelocity: Vector3 , --// 회전 가속도 (deg)
    velocity: Vector3, --// 속도 (v)
    acceleration: Vector3, --// 가속도 (a)
    
    cframe: CFrame, --// Entitiy 의 CFrame
    position: Vector3, -- //위치
    angle: CFrame, --// 회전한 각도 (CFrame Angle) (rad)

    --// 플레그들 (앞의 f 는 flag 라는 뜻)
    flags: {
        fCollideWorld: boolean?, --// World 충돌을 받는지
        fGravity: boolean?, --// 중력의 영향을 받는지
    },

    --// 레이케스트 법선백터
    normal: Vector3,

    --// 충돌여부
    isCollision: boolean,
}, {}))

local physics = {}
physics.world = table.clone(world)

function physics.entity(): Entity
    return setmetatable({
        angularVelocity = Vector3.zero,
        velocity = Vector3.zero,
        acceleration = Vector3.zero,

        cframe = CFrame.new(Vector3.zero),
        position = Vector3.zero,
        angle = CFrame.Angles(0, 0, 0),

        flags = {},

        normal = Vector3.zero,

        isCollision = false,
    }, {})
end

--// v0: 이전위치 v1: 현제위치
function physics.traceLine(v0: Vector3, v1: Vector3): (number, RaycastResult?)
    --// 백터 뺄셈 (v0(이전위치) -> v1(현제위치))
	local vec = v1 - v0

    --// vec 스칼라 (뺀 값 즉 이동거리), 현제위치에서 과거위치에서 현제위치로 쏜 레이케스트
	return vec.Magnitude, workspace:Raycast(v0, vec.Unit * vec.Magnitude)
end

function physics.frame(self: Entity, deltaTime: number)
    --// gravity 를 적용한후 위치
    local currentPosition = physics.physicsGravity(self, deltaTime) + self.position
    
    --// 각속도 처리
    local currentAngle = physics.physicsAngular(self, deltaTime) * self.angle

    --// 충돌처리등..
    physics.physicsTrace(self, self.position, currentPosition)
    
    --// self 의 cframe 에 중력, 회전 적용
    self.cframe = CFrame.new(vector_main_utils.getXYZ(currentPosition)) * currentAngle
    self.position = currentPosition
    self.angle = currentAngle
end

function physics.physicsAngular(self: Entity, deltaTime: number)
    --// 회전 적용 (라디안)
    return CFrame.Angles(vector_main_utils.getXYZ(self.angularVelocity * deltaTime * math.pi / 180))
end

--// v0: 이전위치 v1: 현제위치
function physics.physicsTrace(self: Entity, v0: Vector3, v1: Vector3)
    --// trace (레이가 이동한 거리 (스칼라), raycast result)
    local distance, result = physics.traceLine(v0, v1)

    --// self 가 충돌하지 않음 으로 변경
    self.isCollision = false

    --// result 가 없으면 반환
    if not result then
        return
    end

    --// distance 는 실제 이동거리 result.Distance 는 충돌지점과의 거리
    --// 만약 이 둘이 같을때 나누면 몫은 1, 즉 충돌하지 않았다는뜻 
    --// 충돌하지 않았기에 리턴
    if result.Distance / distance == 1 then
        return
    end

    --// self 의 normal 을 설정
    self.normal = result.Normal

    --// self 가 충돌함으로 변경
    self.isCollision = true
end

function physics.physicsGravity(self: Entity, deltaTime: number): Vector3
    --// 중력의 영향을 받지 않는다면 움직이지 않음
    if not self.flags.fGravity then
        return Vector3.zero
    end

    --// 현제 엔티티의 속도
    local velocity = self.velocity

    --// 중력을 적용한 y 속도 (현제 y - 중력 * dt)
    --// 등가속도 운동의 기본공식 (속도) v = v0 + at
    --// 중력은 아래로 작용하기에 중력가속도(a)를 빼줌
    --// 즉 현제 속도 (v0) - 중력가속도 (a) * deltaTime (t)
    local newYVelocity = velocity.Y - physics.world.gravity * deltaTime

    --// 현제속도에 중력을 적용
    velocity = vector_main_utils.setY(velocity, newYVelocity)

    --// 현제속도에 중력을 적용
    self.velocity = velocity

    --// 이동한 거리를 반환
    --// y 는 평균 이동 속도에 dt 를 곱한값
    velocity = velocity * deltaTime
    velocity = vector_main_utils.setY(velocity, ((velocity.Y + newYVelocity) / 2) * deltaTime)
    
    return velocity
end

return physics
