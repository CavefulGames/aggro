local physics = require('./physics')
local world = require('./world')
local vector_main_utils = require('./vector_main_utils')

export type Entity = physics.Entity & {
    flags: {
        --// 느린 중력의 영향을 받는지 (fGravity 가 켜저있다면 적용돼지 않음)
        fSlowGravity: boolean?,
    }
}

local tempentity = {}
tempentity.world = world

function tempentity.entity(): Entity
    return physics.entity() :: Entity
end

function tempentity.frame(self: Entity, deltaTime: number)
    --// 레이케스트가 아무곳에도 닿지 않았을때 적용해줄 중력 (음수)
    local gravity = tempentity.world.gravity * -deltaTime

    --// flag 중에 느린 중력이 켜져있을때 적용시킬 중력
    local gravitySlow = gravity * 0.5

    --// 나중에 raycast 쓸때 사용할 origin
    local localOrigin = self.cframe.Position

    --// 충돌 비활성화
    self.isCollision = false

    --// v += a * dt
    self.velocity = self.velocity + self.acceleration * deltaTime
    
    --// cframe 에 속도 더해주고 각도설정
    self.cframe = CFrame.new(localOrigin + self.velocity * deltaTime) * CFrame.Angles(self.cframe:ToEulerAnglesXYZ())

    --// 속도로 회전 제어
    if self.flags.fRotate then
        --// 엥귤러 벨로시티를 velocity * dt 로 변경 
        self.angularVelocity = self.velocity * deltaTime
    end

    --// 회전 적용 (라디안)
    local angularVelocity = self.angularVelocity * math.pi / 180
    self.cframe *= CFrame.Angles(vector_main_utils.getXYZ(angularVelocity))

    --// trace (레이가 이동한 거리, raycast result)
    local distance, result = physics.traceLine(localOrigin, self.cframe.Position)
    
    --// 만약 충돌하지 않았다면
    if not result then
        --// 기본 중력의 영향을 받는 상태라면
        if self.flags.fGravity then
            --// velocity 의 y 에 중력만 더해줌
            self.velocity = vector_main_utils.setY(self.velocity, gravity)
        --// 느린 중력의 영향을 받는 상태라면
        elseif self.flags.fSlowGravity then
            --// velocity 의 y 에 Slow 상태일때의 중력을 더해줌 (gravity * 0.5)
            self.velocity = vector_main_utils.setY(self.velocity, gravitySlow)
        end

        --// 리턴
        return
    end

    --// 충돌처리를 안한다면 리턴
    if not self.flags.fCollideWorld then
        return        
    end

    --// 다른곳에서도 trace 로 사용하여야 하기 때문에 따로 self 에 넣어줌
    self.normal = result.Normal

    --// distance 는 실제 이동거리 result.Distance 는 충돌지점과의 거리
    --// 만약 이 둘이 같을때 나누면 몫은 1, 즉 충돌하지 않았다는뜻 
    --// 충돌하지 않았기에 리턴
    if result.Distance / distance == 1 then
        return
    end

    --// 감쇠 계수 (기본값은 1)
    local dampingFactor = 1
    
    --// 충돌 활성화
    self.isCollision = true

    --// 중력의 영향을 받는다면
    if self.flags.fGravity or self.flags.fSlowGravity then
        --// 감쇠 계수에 0.5 를 곱함
        dampingFactor *= 0.5

        --// Trace Normal 이 1 에 가까움 (바닥에 닿았다면)
        if result.Normal.Y > 0.9 then
            --// velocity y 가 0 이랑 같거나 작음 (밑으로 떨어지는중이거나 정지한 상태) 이고 낙하속도가 (-g * dt * 3) 보다 크다면
            if self.velocity.Y <= 0 and self.velocity.Y >= gravity * 3 then
                --// 감쇠 계수를 0 으로
                dampingFactor = 0

                --// 플레그 비활성화
                self.flags.fRotate = false
                self.flags.fSlowGravity = false
                self.flags.fGravity = false
                self.flags.fCollideWorld = false
                
                --// 엔티티를 착지 상태로
                local _, y, _ = self.cframe:ToEulerAnglesYXZ()
                self.cframe = CFrame.new(self.cframe.Position) * CFrame.Angles(0, y, 0)
            end
        end
    end

    --// 감쇠계수가 0 이 아니라면 (정지하지 않았다면)
    if dampingFactor ~= 0 then
        --// velocity 와 Normal 의 내적 
        --// (d = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z)
        --// A * B = |A||B|cos(S)
        --// A * B > 0 -> 비슷한 방향
        --// A * B == 0 -> 서로 수직 
        --// A * B < 0 -> 반대 방향

        --// 예시
        --// a = (1, 0, 0), b = (2, 0, 0) -> (2 * 1 + 0 + 0 = 2) > 0 --> 비슷한 방향
        --// a = (0, 1, 0), b = (1, 0, 0) -> (0 * 1 + 1 * 0 + 0 = 0) == 0 --> 서로 수직
        --// a = (1, 0, 0), b = (-1, 0, 0) -> (1 * -1 + 0 + 0 = -1) < 0 --> 반대 방향

        --// 법선 백터 (Normal Vector) 는 표면에서 수직인 백터임
        --// 이 법선 백터와 velocity 를 Dot 함
        --// 만약 이 프로덕트 값이 크다면 법선백터와 Velocity 의 방향이 비슷함 
        --// -> 즉 더 강하게 부딪침 (즉 강도)

        local productVelocity = self.velocity:Dot(result.Normal)

        --// 백터 반사공식
        --// von = (-v * n) * n
        --// r(반사백터) = v + 2 * (-v * n) * n = v - 2 * (v * n) * n
        --// 마지막에 n 곱하는건 스칼라를 백터로 바꾸기 위한거니깐 건너뜀 (productVelocity 는 스칼라)
        self.velocity = self.velocity + -2 * productVelocity * result.Normal

        --// y 를 역백터
        local x, y, z = self.cframe:ToEulerAnglesXYZ()
        self.cframe = CFrame.new(self.cframe.Position) * CFrame.Angles(x, -y, z)
    end

    --// 감쇠계수가 1 이 아니라면 (중력의 영향을 받는다면)
    if dampingFactor ~= 1 then
        --// velocity 에 감쇠계수를 곱함
        self.velocity = self.velocity * dampingFactor

        --// 모든 각도를 0.9 씩 곱해줌
        local x, y, z = self.cframe:ToEulerAnglesXYZ()
		self.cframe = CFrame.new(self.cframe.Position) * CFrame.Angles(x * 0.9, y * 0.9, z * 0.9)
    end
end

return tempentity
